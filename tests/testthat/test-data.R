describe("julich_cortical atlas", {
  it("is a ggseg_atlas", {
    expect_s3_class(julich_cortical(), "ggseg_atlas")
    expect_s3_class(julich_cortical(), "cortical_atlas")
  })

  it("is valid", {
    expect_true(is_ggseg_atlas(julich_cortical()))
  })

  it("renders with ggseg", {
    p <- plot(julich_cortical()) + theme_void()
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
})
