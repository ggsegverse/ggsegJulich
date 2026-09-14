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

# ── Create LUT with type column ───────────────────────────────────
# The `type` column is what keeps the cytoarchitectonic areas on the
# cortical surface. Without it the pipeline falls back to a vertex-count
# heuristic, which sends small-but-cortical parcels (Area 45, Area TE 3,
# the insular and orbitofrontal series) into the subcortical atlas. Every
# `Area_*` parcel, the GapMaps and the entorhinal cortex are cortex; the
# hippocampal subfields, amygdalar and basal forebrain nuclei, the bed
# nucleus, the metathalamus and the deep cerebellar nuclei are not.
labels <- readLines(label_file)[-1]
label_names <- vapply(
  labels,
  function(l) gsub(" ", "_", gsub("^[0-9]+ '|'$", "", l)),
  character(1),
  USE.NAMES = FALSE
)

is_cortical <- grepl("^Area_", label_names) |
  grepl("GapMap", label_names) |
  grepl("^Entorhinal_Cortex", label_names)

# The release ships names only, so the colours are ours to choose. Give
# each structure a hue of its own, spread over the circle and stepped
# through three luminances so neighbouring hues still separate, and give a
# structure's two sides the same colour, the way FreeSurfer's own tables
# do. Cortical and subcortical structures are spread separately, since
# they end up in separate atlases.
structure_colours <- function(labels) {
  structures <- unique(sub("_(left|right)$", "", labels))
  n <- length(structures)
  cols <- grDevices::hcl(
    h = seq(0, 360, length.out = n + 1L)[seq_len(n)],
    c = 75,
    l = rep_len(c(45, 65, 82), n)
  )
  grDevices::col2rgb(cols[match(sub("_(left|right)$", "", labels), structures)])
}

rgb_matrix <- matrix(0L, nrow = 3, ncol = length(label_names))
rgb_matrix[, is_cortical] <- structure_colours(label_names[is_cortical])
rgb_matrix[, !is_cortical] <- structure_colours(label_names[!is_cortical])

lut <- data.frame(
  idx = seq_along(label_names),
  label = label_names,
  R = as.integer(rgb_matrix[1, ]),
  G = as.integer(rgb_matrix[2, ]),
  B = as.integer(rgb_matrix[3, ]),
  A = 0L,
  type = ifelse(is_cortical, "cortical", "subcortical"),
  stringsAsFactors = FALSE
)
cli::cli_alert_info(
  "{sum(is_cortical)} cortical, {sum(!is_cortical)} subcortical labels"
)
# write_lut() writes the FreeSurfer columns only, and the type column is
# worth keeping alongside them as a record of how the split was made.
writeLines(
  sprintf(
    "%d %s %d %d %d %d %s",
    lut$idx, lut$label, lut$R, lut$G, lut$B, lut$A, lut$type
  ),
  file.path(source_dir, "julich_LUT.txt")
)

# ── Create atlas ──────────────────────────────────────────────────
atlases <- create_wholebrain_from_volume(
  input_volume = mpm_file,
  input_lut = lut,
  atlas_name = "julich",
  output_dir = "data-raw",
  # Intermediates are cached by step, not by LUT content, so a changed
  # lookup table would otherwise be ignored on a re-run.
  skip_existing = FALSE,
  cleanup = FALSE
)

# ── Polish geometry ───────────────────────────────────────────────
# The pipelines hand back raw voxel-traced outlines. Simplify first, so
# the smoothing has the last word on the outline.
.julich_cortical <- atlases$cortical |>
  atlas_simplify(keep = 0.3) |>
  atlas_smooth(smoothness = 0.4)

.julich_subcortical <- atlases$subcortical |>
  atlas_simplify(keep = 0.2, labels = "^cortex") |>
  atlas_simplify(keep = 0.25, exclude = "^cortex") |>
  atlas_smooth(smoothness = 0.4)

cat("Cortical regions:", nrow(.julich_cortical$core), "\n")
cat("Subcortical regions:", nrow(.julich_subcortical$core), "\n")

usethis::use_data(
  .julich_cortical,
  .julich_subcortical,
  overwrite = TRUE,
  compress = "xz",
  internal = TRUE
)
