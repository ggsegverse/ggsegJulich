# Create Julich-Brain Cytoarchitectonic Atlas
#
# Source: https://search.kg.ebrains.eu/instances/
#   ab191c17-8cd8-4622-aaac-eee11b2fa670
# Reference: Amunts K, et al. (2020). Science, 369(6506):988-992.
# Date obtained: 2026-03-28
#
# Run with: Rscript data-raw/make_atlas.R

library(ggseg.extra)
library(ggseg.formats)

Sys.setenv(FREESURFER_HOME = "/Applications/freesurfer/7.4.1")

# lut_classify_anatomy() and atlas_smooth(method = "chaikin").
stopifnot(packageVersion("ggseg.extra") >= "1.9.9.9031")

source_dir <- here::here("data-raw", "source")
pmap_file <- file.path(
  source_dir,
  "JULICH_BRAIN_CYTOARCHITECTONIC_MAPS_2_9_MNI152_2009C_NONL_ASYM.pmaps.nii.gz"
)
label_file <- file.path(
  source_dir,
  "JULICH_BRAIN_CYTOARCHITECTONIC_MAPS_2_9_MNI152_2009C_NONL_ASYM.txt"
)

# ── Create maximum probability map ───────────────────────────────
mpm_file <- file.path(source_dir, "julich_mpm.nii.gz")

if (!file.exists(mpm_file)) {
  cli::cli_alert_info("Creating maximum probability map from 4D pmaps...")
  vol <- RNifti::readNifti(pmap_file)
  dims <- dim(vol)
  mpm <- array(0L, dim = dims[1:3])

  for (i in seq_len(dims[1])) {
    slice <- vol[i, , , ]
    max_prob <- apply(slice, c(1, 2), max)
    max_idx <- apply(slice, c(1, 2), which.max)
    max_idx[max_prob == 0] <- 0L
    mpm[i, , ] <- max_idx
  }

  out <- RNifti::asNifti(mpm, reference = vol)
  RNifti::writeNifti(out, mpm_file)
  n_regions <- length(unique(as.vector(mpm[mpm > 0])))
  cli::cli_alert_success("MPM written with {n_regions} regions")
}

# ── Classify labels by anatomy ────────────────────────────────────
label_names <- gsub(
  " ",
  "_",
  gsub("^[0-9]+ '|'$", "", readLines(label_file)[-1])
)
structure_of <- function(labels) {
  sub("^[lr]h_", "", sub("_(left|right)$", "", labels))
}

lut <- lut_classify_anatomy(
  mpm_file,
  data.frame(
    idx = seq_along(label_names),
    label = label_names,
    stringsAsFactors = FALSE
  )
)

# ── Editorial overrides ───────────────────────────────────────────
# The eight deep cerebellar nuclei are anatomically cerebellar, and the
# classifier says so. But a ggsegverse cerebellar atlas is a SUIT
# flatmap: create_cerebellar_from_volume() samples the volume at the
# vertices of the SUIT *cortical* surface, and these nuclei sit in the
# cerebellar white matter. Sent down that pipeline they are smeared over
# whatever cerebellar cortex lies nearest; in the subcortical slices they
# read correctly as nuclei.
cerebellar_nuclei <- paste0(
  rep(
    c("Dorsal_Dentate", "Ventral_Dentate", "Interposed", "Fastigial"),
    each = 2
  ),
  "_Nucleus_(Cerebellum)_",
  c("left", "right")
)

# Id5 and Ch 123 came back cortical on one side and subcortical on the
# other, and a structure that lands in two atlases renders as half a brain
# in each. Id5 is insular cortex; the Ch nuclei are basal forebrain.
forced_cortical <- paste0("Area_Id5_(Insula)_", c("left", "right"))
forced_subcortical <- c(
  paste0("Ch_123_(Basal_Forebrain)_", c("left", "right")),
  cerebellar_nuclei
)
stopifnot(all(c(forced_cortical, forced_subcortical) %in% lut$label))

# These two vectors are the only statement of the override. They go to
# the pipeline as arguments, which is the path that decides, and into
# `type` so the lookup table on disk describes the atlas that was built.
lut$type[lut$label %in% forced_cortical] <- "cortical"
lut$type[lut$label %in% forced_subcortical] <- "subcortical"
stopifnot(
  # A structure whose two sides disagree would be split across atlases.
  all(tapply(lut$type, structure_of(lut$label), dplyr::n_distinct) == 1L),
  # Nothing is left for the cerebellar pipeline to build.
  !any(lut$type == "cerebellar")
)

# ── Palette ───────────────────────────────────────────────────────
# Each structure gets a hue of its own, spread over the circle and
# stepped through three luminances so neighbouring hues still separate,
# and a structure's two sides share it, the way FreeSurfer's own tables
# do. The two atlases are drawn from the ramp separately, so a colour is
# unique within an atlas rather than within the table.
structure_colours <- function(labels) {
  structures <- unique(structure_of(labels))
  n <- length(structures)
  cols <- grDevices::hcl(
    h = seq(0, 360, length.out = n + 1L)[seq_len(n)],
    c = 75,
    l = rep_len(c(45, 65, 82), n)
  )
  # hcl() clips out-of-gamut colours silently, which at a larger n would
  # hand back two structures the same colour.
  stopifnot(!anyDuplicated(cols))
  cols[match(structure_of(labels), structures)]
}

is_cortical <- lut$type == "cortical"
colours <- character(nrow(lut))
colours[is_cortical] <- structure_colours(lut$label[is_cortical])
colours[!is_cortical] <- structure_colours(lut$label[!is_cortical])

lut[c("R", "G", "B")] <- as.data.frame(t(grDevices::col2rgb(colours)))
lut$A <- 0L
write_lut(lut, file.path(source_dir, "julich_LUT.txt"))

# ── Create atlas ──────────────────────────────────────────────────
atlases <- create_wholebrain_from_volume(
  input_volume = mpm_file,
  input_lut = lut,
  atlas_name = "julich",
  output_dir = "data-raw",
  cortical_labels = forced_cortical,
  subcortical_labels = forced_subcortical,
  # Intermediates are cached by step, not by LUT content, so a changed
  # lookup table would otherwise be ignored on a re-run.
  skip_existing = FALSE,
  cleanup = FALSE
)

# ── Reconcile labels in against regions out ───────────────────────
# IF (Amygdala) never wins the maximum probability map, so it has no
# voxels to project. Anything else going missing is a pipeline fault.
# The pipeline's own name mangling decides what a label is called on the
# way out, so borrow it rather than guess at it.
expected_absent <- paste0("IF_(Amygdala)_", c("left", "right"))
# The same list, as the labels the built atlas is expected to carry, goes
# to the tests: it is read off the source release rather than off the
# atlas, so a later build that quietly drops regions fails there too.
writeLines(
  sort(ggseg.extra:::sanitize_label(setdiff(label_names, expected_absent))),
  here::here("tests", "testthat", "source-labels.txt")
)
built <- c(atlases$cortical$core$label, atlases$subcortical$core$label)
missing <- setdiff(
  ggseg.extra:::sanitize_label(setdiff(lut$label, expected_absent)),
  sub("^[lr]h_", "", built)
)
if (length(missing) > 0) {
  cli::cli_abort("{length(missing)} label{?s} reached no atlas: {missing}")
}

# ── Polish geometry ───────────────────────────────────────────────
# Simplify first, so the smoothing has the last word on the outline.
#
# The `cortex` context is a sulcal ribbon where every gyral crown and
# sulcal fragment is a contour ring of its own, so simplifying it costs
# rings rather than only vertices: `keep = 0.5` leaves 92 of the
# ribbon's 122 rings, where `keep = 0.85` leaves 113. The rings that go
# are small crowns and sulcal fragments, deleted outright rather than
# simplified. That is a deliberate trade: the context is a silhouette to
# read structures against, not an anatomical claim, and the smoother
# outline reads better than the busier one. Chaikin's corner cutting
# takes off the voxel staircase without moving the rings that remain;
# the default `close` method dilates and then erodes, which fattens the
# ribbon until adjacent sulci merge.
#
# The structures are the opposite case: solid nuclei with nothing
# interior to lose, so they take the firmer simplification and `close`.
.julich_cortical <- atlases$cortical |>
  atlas_simplify(keep = 0.3) |>
  atlas_smooth(smoothness = 0.4)

.julich_subcortical <- atlases$subcortical |>
  atlas_simplify(keep = 0.5, labels = "^cortex") |>
  atlas_smooth(smoothness = 0.35, labels = "^cortex", method = "chaikin") |>
  atlas_simplify(keep = 0.25, exclude = "^cortex") |>
  atlas_smooth(smoothness = 0.4, exclude = "^cortex")

cli::cli_alert_info("Cortical rows: {nrow(.julich_cortical$core)}")
cli::cli_alert_info("Subcortical rows: {nrow(.julich_subcortical$core)}")

usethis::use_data(
  .julich_cortical,
  .julich_subcortical,
  overwrite = TRUE,
  compress = "xz",
  internal = TRUE
)
