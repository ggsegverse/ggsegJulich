#' Julich-Brain Cytoarchitectonic Atlas
#'
#' Maximum probability map from 296 cytoarchitectonic probability maps
#' with 294 labelled regions.
#'
#' @family ggseg_atlases
#' @references Amunts K, et al. (2020). Julich-Brain: A 3D probabilistic
#'   atlas of the human brain's cytoarchitecture. *Science*, 369(6506):988-992.
#'   \doi{10.1126/science.abb4588}
#' @return A [ggseg.formats::ggseg_atlas] object (subcortical).
#' @import ggseg.formats
#' @export
#' @examples
#' julich()
#' plot(julich())
julich <- function() .julich
