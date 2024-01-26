infobutton <- function(id) {
  div(
    id = id, class = "infobutton",
    "i"
  )
}

custom_card <- function(id, title, ..., info = TRUE, kpi = FALSE) {
  tags$section(
    class = ifelse(kpi, "card kpi_card", "card"),
    tags$header(
      class = "card__header",
      h3(class="card__heading", title),
      if(info) infobutton(id)
    ),
    div(
      class = "card__content", style = "height: 100%;",
      ...
    )
  )
}
