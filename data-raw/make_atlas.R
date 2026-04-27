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
labels <- readLines(label_file)[-1]
lut <- data.frame(
  idx = seq_along(labels),
  label = vapply(labels, function(l) {
    name <- gsub("^[0-9]+ '|'$", "", l)
    gsub(" ", "_", name)
  }, character(1)),
  R = 0L, G = 0L, B = 0L, A = 0L,
  stringsAsFactors = FALSE
)

lut$type <- ifelse(
  grepl("Cerebellum|Dentate_Nucleus|Fastigial_Nucleus|Interposed_Nucleus",
        lut$label),
  "cerebellar",
  "cortical"
)
cli::cli_alert_info("Cerebellar labels: {sum(lut$type == 'cerebellar')}")

# ── Create atlas ──────────────────────────────────────────────────
suit_flat <- here::here("..", "data-raw", "tpl-SUIT_flat.surf.gii")

atlases <- create_wholebrain_from_volume(
  input_volume = mpm_file,
  input_lut = lut,
  atlas_name = "julich",
  output_dir = "data-raw",
  suit_surface = suit_flat,
  skip_existing = FALSE,
  cleanup = FALSE
)

.julich_cortical <- atlases$cortical
.julich_subcortical <- atlases$subcortical
.julich_cerebellar <- atlases$cerebellar

if (!is.null(.julich_cerebellar)) {
  usethis::use_data(.julich_cortical, .julich_subcortical,
    .julich_cerebellar, overwrite = TRUE, compress = "xz", internal = TRUE)
} else {
  usethis::use_data(.julich_cortical, .julich_subcortical,
    overwrite = TRUE, compress = "xz", internal = TRUE)
}
