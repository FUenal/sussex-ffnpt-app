download_ui <- grid(
        grid_template = grid_template(
                default = list(
                        areas = rbind(
                                c("kpi4", "kpi5", "kpi6"),
                                c("card4" , "card4", "card4"),
                                c("card5" , "card5", "card5"),
                                c("card6" , "card6", "card6")
                        ),
                        cols_width = c("1fr", "1fr", "1fr"),
                        rows_height = c("150px", "1fr", "1fr", "1fr")
                ),
                mobile = list(
                        areas = rbind(
                                c("kpi4"),
                                c("kpi5"),
                                c("kpi6"),
                                c("card4"),
                                c("card5"),
                                c("card6")
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
                                   uiOutput("mbl_count1")
                           ),
                           kpi = TRUE
        ),
        kpi5 = custom_card("sr_count",
                           "Subsidy reductions",
                           div(
                                   class = "card_metric",
                                   uiOutput("sr_count1")
                           ),
                           kpi = TRUE
        ),
        kpi6 = custom_card("div_count",
                           "Divestments",
                           div(
                                   class = "card_metric",
                                   uiOutput("div_count1")
                           ),
                           kpi = TRUE
        ),
        card4 = custom_card("download_card_content_card1",
                            "Policy download: Moratoria, bans, limits",
                            DT::dataTableOutput(outputId = "dataTable4"),
        ),
        card5 = custom_card("download_card_content_card2",
                            "Policy download: Subsidy reductions",
                            DT::dataTableOutput(outputId = "dataTable5")
        ),
        card6 = custom_card("download_card_content_card3",
                            "Policy download: Divestments",
                            DT::dataTableOutput(outputId = "dataTable6")
        )
)

