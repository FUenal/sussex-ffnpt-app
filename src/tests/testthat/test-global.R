context("Test shiny boot.")
setwd("../../")

test_that("Shiny dependencies are OK!", {
        expect_error(source("global.R"), NA)
})
