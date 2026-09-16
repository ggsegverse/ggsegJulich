library(ggseg)
library(ggplot2)

ring_vertices <- function(atlas, context) {
  geom <- ggseg.formats::atlas_polygons(atlas)
  rows <- which(grepl("^cortex", geom$label) == context)
  do.call(
    rbind,
    lapply(rows, function(i) {
      d <- geom$geometry[[i]]
      stats::aggregate(
        list(vertices = d$x),
        by = list(view = d$view, group = d$group, subgroup = d$subgroup),
        FUN = length
      )
    })
  )
}
