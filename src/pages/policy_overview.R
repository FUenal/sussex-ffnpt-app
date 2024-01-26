policy_overview_ui <- grid(
  grid_template = grid_template(
    default = list(
      areas = rbind(
        c("kpi4" , "kpi5", "kpi6"),
        c("card1" , "card1", "card1"),
        c("card2" , "card2", "card2"),
        c("card3" , "card3", "card3")
      ),
      cols_width = c("1fr", "1fr", "1fr"),
      rows_height = c("150px", "1fr", "1fr", "1fr")
    ),
    mobile = list(
      areas = rbind(
        c("kpi4"),
        c("kpi5"),
        c("kpi6"),
        c("card1"),
        c("card2"),
        c("card3")
      ),
      cols_width = c("1fr"),
      rows_height = c("150px", "150px", "150px", "1fr", "1fr", "1fr")
    )
  ),
  container_style = "
    gap: 50px;
    height: 100%;
    max-width: 1600px;
  ",
  # area_styles = list(
  #   map = "align-self: end; height: 100%;",
  #   card1 = "height: 100%;",
  #   card2 = "height: 100%;"
  # ),
  kpi4 = custom_card("mbl_count",
                     "Moratoria, bans, limits",
                     div(
                       class = "card_metric",
                       uiOutput("mbl_count")
                     ),
                     kpi = TRUE
  ),
  kpi5 = custom_card("sr_count",
                     "Subsidy reductions",
                     div(
                       class = "card_metric",
                       uiOutput("sr_count")
                     ),
                     kpi = TRUE
  ),
  kpi6 = custom_card("div_count",
                     "Divestments",
                     div(
                       class = "card_metric",
                       uiOutput("div_count")
                     ),
                     kpi = TRUE
  ),
  card1 = custom_card("cumulative_mbl_plot_card",
                      "Moratoria, bans, limits",
                      highchartOutput("cumulative_mbl_plot")
  ),
  card2 = custom_card("cumulative_sr_plot_card",
                      "Subsidy reductions",
                      highchartOutput("cumulative_sr_plot")
  ),
  card3 = custom_card("cumulative_div_plot_card",
                      "Divestments (Governmental & Non-governmental)",
                      highchartOutput("cumulative_div_plot")
  )
)

