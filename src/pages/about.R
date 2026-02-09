rmarkdown::pandoc_convert(
  normalizePath("./content/about.docx"), to = "html",
  output = paste0(tempdir(), "/about.html")
)

about_ui <- div(
  sapply(readLines(paste0(tempdir(), "/about.html")), . %>% {
    stringr::str_replace_all(., c(
      "href" = "target=\"_blank\" href",
      "â€™" = "'",
      "â€˜"= "'",
      "'" = "'",
      "'" = "'",
      "media/" = "media/about/",
      "16/01/24" = APP_LAST_UPDATED
    ))
  }, simplify = TRUE) %>% HTML()
)
