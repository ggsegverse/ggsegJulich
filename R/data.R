#' Julich-Brain Cortical Atlas
#'
#' Cortical regions from the maximum probability map of 296
#' cytoarchitectonic probability maps.
#'
#' @family ggseg_atlases
#' @family cortical_atlases
#'
#' @references Amunts K, et al. (2020). Julich-Brain: A 3D probabilistic
#'   atlas of the human brain's cytoarchitecture. *Science*, 369(6506):988-992.
#'   \doi{10.1126/science.abb4588}
#' @return A [ggseg.formats::ggseg_atlas] object (cortical).
#' @import ggseg.formats
#' @export
#' @examples
#' julich_cortical()
# nolint next: object_usage_linter.
julich_cortical <- function() .julich_cortical

#' Julich-Brain Subcortical Atlas
#'
#' Subcortical regions from the maximum probability map of 296
#' cytoarchitectonic probability maps.
#'
#' @family ggseg_atlases
#' @family subcortical_atlases
#'
#' @references Amunts K, et al. (2020). Julich-Brain: A 3D probabilistic
#'   atlas of the human brain's cytoarchitecture. *Science*, 369(6506):988-992.
#'   \doi{10.1126/science.abb4588}
#' @return A [ggseg.formats::ggseg_atlas] object (subcortical).
#' @export
#' @examples
#' julich_subcortical()
# nolint next: object_usage_linter.
julich_subcortical <- function() .julich_subcortical
