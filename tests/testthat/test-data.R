describe("julich_cortical atlas", {
  it("is a ggseg_atlas", {
    expect_s3_class(julich_cortical(), "ggseg_atlas")
    expect_s3_class(julich_cortical(), "cortical_atlas")
  })

  it("is valid", {
    expect_true(is_ggseg_atlas(julich_cortical()))
  })

  it("renders with ggseg", {
    p <- ggplot() +
      geom_brain(atlas = julich_cortical(), mapping = aes(fill = label)) +
      theme_void()
    expect_s3_class(p, "gg")
  })
})

describe("julich_subcortical atlas", {
  it("is a ggseg_atlas", {
    expect_s3_class(julich_subcortical(), "ggseg_atlas")
  })

  it("is valid", {
    expect_true(is_ggseg_atlas(julich_subcortical()))
  })

  it("renders with ggseg", {
    p <- ggplot() +
      geom_brain(atlas = julich_subcortical(), mapping = aes(fill = label)) +
      theme_void()
    expect_s3_class(p, "gg")
  })
})

describe("region split", {
  it("keeps the cytoarchitectonic areas cortical", {
    regions <- atlas_regions(julich_cortical())
    expect_equal(length(regions), 125)
    patterns <- c("^area 7p spl", "^area op3 poperc", "^area pf ipl")
    expect_true(all(vapply(
      patterns,
      function(p) any(grepl(p, regions)),
      logical(1)
    )))
  })

  it("puts no region in both atlases", {
    expect_length(
      intersect(
        atlas_regions(julich_cortical()),
        atlas_regions(julich_subcortical())
      ),
      0
    )
  })

  it("draws each region once per hemisphere it reaches", {
    core <- julich_cortical()$core
    expect_false(anyDuplicated(core[c("hemi", "label")]) > 0)
    # Fo1 and Fo2 sit on the midline: their right-hemisphere labels also
    # reach left-hemisphere vertices, so 125 regions come to 252 rows.
    expect_equal(nrow(core), 252)
  })

  it("keeps hippocampus, amygdala and metathalamus subcortical", {
    regions <- atlas_regions(julich_subcortical())
    expect_equal(length(regions), 22)
    expect_true(any(grepl("hippocampus", regions)))
    expect_true(any(grepl("amygdala", regions)))
    expect_true(any(grepl("metathalamus", regions)))
  })

  it("carries the eight deep cerebellar nuclei in the subcortical atlas", {
    nuclei <- "dentate|interposed|fastigial"
    expect_length(
      grep(nuclei, julich_subcortical()$core$region, value = TRUE),
      8
    )
    expect_false(any(grepl(nuclei, atlas_regions(julich_cortical()))))
  })
})

describe("palette", {
  expect_structure_colour <- function(atlas) {
    palette <- atlas_palette(atlas)
    expect_false(anyNA(palette))
    structure <- atlas$core$region[match(names(palette), atlas$core$label)]
    by_structure <- split(unname(palette), structure)
    expect_equal(length(unique(palette)), length(by_structure))
    expect_true(all(vapply(
      by_structure,
      function(x) length(unique(x)) == 1L,
      logical(1)
    )))
  }

  it("gives each cortical structure one colour, both hemispheres", {
    expect_structure_colour(julich_cortical())
  })

  it("gives each subcortical structure one colour, both hemispheres", {
    expect_structure_colour(julich_subcortical())
  })
})

describe("subcortical geometry", {
  it("polishes the cortex context gently", {
    rings <- ring_vertices(julich_subcortical(), context = TRUE)
    # Ventricles and temporal horns are interior rings, and the detail
    # that draws them is what the structures' firmer simplification
    # spends first: that pass leaves the context under 1500 vertices.
    expect_gt(sum(rings$subgroup > 1), 10)
    expect_gt(sum(rings$vertices), 2000)
  })

  it("leaves the structures smooth rather than faceted", {
    rings <- ring_vertices(julich_subcortical(), context = FALSE)
    expect_gt(stats::median(rings$vertices), 20)
  })
})
