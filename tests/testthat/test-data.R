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
      geom_brain(atlas = julich_cortical(), show.legend = FALSE) +
      theme_void()
    expect_s3_class(p, "gg")
  })

  it("keeps the cytoarchitectonic areas on the surface", {
    labels <- julich_cortical()$core$label
    expect_true(sum(grepl("Area_45_IFG", labels)) == 2)
    expect_true(sum(grepl("_Insula_", labels)) > 20)
  })

  it("labels each hemisphere with its own side", {
    core <- julich_cortical()$core
    expect_true(all(grepl("_right$", core$label[core$hemi == "right"])))
    expect_gt(sum(grepl("_left$", core$label[core$hemi == "left"])), 100)
  })
})

describe("julich_subcortical atlas", {
  it("is a ggseg_atlas", {
    expect_s3_class(julich_subcortical(), "ggseg_atlas")
  })

  it("is valid", {
    expect_true(is_ggseg_atlas(julich_subcortical()))
  })

  it("has no mesh the size of a hemisphere", {
    meshes <- julich_subcortical()$data$meshes$mesh
    sizes <- vapply(meshes, function(x) nrow(x$vertices), integer(1))
    expect_lt(max(sizes), 10000)
  })

  it("carries the hippocampal and cerebellar nuclei", {
    labels <- julich_subcortical()$core$label
    expect_true(all(c(
      "CA1_Hippocampus_left", "HATA_Hippocampus_right",
      "Fastigial_Nucleus_Cerebellum_left", "CGL_Metathalamus_right"
    ) %in% labels))
  })

  it("labels each hemisphere with its own side", {
    core <- julich_subcortical()$core
    expect_true(all(grepl("_right$", core$label[core$hemi == "right"])))
    expect_true(all(grepl("_left$", core$label[core$hemi == "left"])))
  })
})

describe("palettes", {
  it("give the regions of each atlas different colours", {
    expect_gt(length(unique(julich_cortical()$palette)), 1)
    expect_gt(length(unique(julich_subcortical()$palette)), 1)
  })

  it("plot without falling back to automatic colours", {
    expect_no_warning(ggseg.formats::atlas_plot_palette(julich_cortical()))
    expect_no_warning(ggseg.formats::atlas_plot_palette(julich_subcortical()))
  })
})
