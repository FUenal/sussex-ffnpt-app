context("Test preprocess and generate new image data.")
setwd("../../")
img_path <- "image.RData"
pre_path <- "PreprocessingScript.R"

test_that("Preprocess is OK!", {
  if(exists(img_path)) file.remove(img_path)
  expect_error(source("PreprocessingScript.R", ), NA)
  expect_true(file.exists(img_path))
})
