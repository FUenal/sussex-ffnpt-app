rmarkdown::pandoc_convert(
        normalizePath("./content/how_to.docx"), to = "html",
        output = paste0(tempdir(), "/how_to.html")
)

how_to_ui <- div(
        sapply(readLines(paste0(tempdir(), "/how_to.html")), . %>% {
                stringr::str_replace_all(., c(
                        "href" = "target=\"_blank\" href",
                        "â€™" = "’",
                        "â€˜"= "‘",
                        "’" = "'",
                        "‘" = "'",
                        "media/" = "media/howto/"
                ))
        }, simplify = TRUE) %>% HTML()
)

