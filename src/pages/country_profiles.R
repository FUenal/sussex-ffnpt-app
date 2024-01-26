policy_card_content <- tabset(
  id = "details_one_tabs",
  menu_class = "card-menu secondary pointing menu",
  tab_content_class = "",
  list(
    list(
      menu = "Commitments by Fossil Fuel Type",
      id = 'commitments_type',
      content = grid(
        grid_template = grid_template(
          default = list(
            areas = rbind(
              c("chart1" , "chart2", "chart3")
            ),
            cols_width = c("32%", "32%", "32%"),
            rows_height = c("1fr")
          ),
          mobile = list(
            areas = rbind(
              c("chart1"),
              c("chart2"),
              c("chart3")
            ),
            cols_width = c("100%"),
            rows_height = c("1fr", "1fr", "1fr")
          )
        ),
        container_style = "
          height: 100%;
        ",
        chart1 = div(
          style = "padding: 10px",
          highchartOutput("pol_plot_5")
        ),
        chart2 = div(
          style = "padding: 10px",
          highchartOutput("pol_plot_9")
        ),
        chart3 = div(
          style = "padding: 10px",
          highchartOutput("pol_plot_7")
        )
      )
    ),
    list(
      menu = "Commitments by Type and Level",
      id = 'commitments_level',
      content = grid(
        grid_template = grid_template(
          default = list(
            areas = rbind(
              c("chart1" , "chart2", "chart3")
            ),
            cols_width = c("32%", "32%", "32%"),
            rows_height = c("1fr")
          ),
          mobile = list(
            areas = rbind(
              c("chart1"),
              c("chart2"),
              c("chart3")
            ),
            cols_width = c("100%"),
            rows_height = c("1fr", "1fr", "1fr")
          )
        ),
        container_style = "
          height: 100%;
        ",
        chart1 = div(
          style = "padding: 10px",
          highchartOutput("pol_plot_4")
        ),
        chart2 = div(
          style = "padding: 10px",
          highchartOutput("pol_plot_6")
        ),
        chart3 = div(
          style = "padding: 10px",
          highchartOutput("pol_plot_8")
        )
      )
    )
  )
)

policy_sources_card_content <- tabset(
  id = "details_two_tabs",
  menu_class = "card-menu secondary pointing menu",
  tab_content_class = "",
  list(
    list(
      menu = "Sources: Moratoria, Limits, & Bans",
      id = 'sources_mlb',
      content = div(
        style = "padding: 10px;",
        DT::dataTableOutput(outputId = "dataTable1")
      )
    ),
    list(
      menu = "Sources: Subsidy Reductions",
      id = 'sources_sr',
      content = div(
        style = "padding: 10px;",
        DT::dataTableOutput(outputId = "dataTable2")
      )
    ),
    list(
      menu = "Sources: Divestments",
      id = 'sources_div',
      content = div(
        style = "padding: 10px;",
        DT::dataTableOutput(outputId = "dataTable3")
      )
    )
  )
)

fossil_card_content <- tabset(
  id = "details_three_tabs",
  menu_class = "card-menu secondary pointing menu",
  tab_content_class = "",
  list(
    list(
      menu = "Fossil Fuel Production",
      id = "ffp",
      content = div(
        highchartOutput("gas_plot_x"),
        highchartOutput("oil_plot_x"),
        highchartOutput("coal_plot_x")
      )
    ),
    list(
      menu = "CO2 Emissions Oil",
      id = "coeo",
      content = div(
        highchartOutput("oil_co2_plot_x")
      )
    ),
    list(
      menu = "CO2 Emissions Gas",
      id = "coeg",
      content = div(
        highchartOutput("gas_co2_plot_x")
      )
    ),
    list(
      menu = "CO2 Emissions Coal",
      id = "coec",
      content = div(
        highchartOutput("coal_co2_plot_x")
      )
    )
  )
)

country_profiles_ui <- grid(
  grid_template = grid_template(
    default = list(
      areas = rbind(
        c("kpi1", "kpi2", "kpi3", "kpi7"),
        c("map", "map", "map", "map"),
        c("dropdown", "dropdown", "dropdown", "dropdown"),
        c("country_title", "country_title", "country_title", "country_title"),
        c("card1", "card1", "card1", "card1"),
        c("card2", "card2", "card2", "card2"),
        c("card3", "card3", "card3", "card3")
      ),
      cols_width = c("1fr", "1fr", "1fr", "1fr"),
      rows_height = c("150px", "minmax(400px, 60vh)", "auto", "auto")
    ),
    mobile = list(
      areas = rbind(
        c("kpi1"),
        c("kpi2"),
        c("kpi3"),
        c("kpi7"),
        c("map"),
        c("country_title"),
        c("card1"),
        c("card2"),
        c("card3")
      ),
      cols_width = c("1fr"),
      rows_height = c("150px", "150px", "150px", "minmax(400px, 60vh)", "auto", "auto")
    )
  ),
  container_style = "
    gap: 50px;
    height: 100%;
    max-width: 1600px;
  ",
  area_styles = list(
    map = "align-self: end; height: 100%;",
    dropdown = "text-align: center; justify-content: center; display: flex; margin: -20px; z-index: 10000;",
    card1 = "height: 100%;",
    card2 = "height: 100%;"
  ),
  kpi1 = custom_card("policy_count",
                     "Total Supply-Side Commitments",
                     div(
                       class = "card_metric",
                       uiOutput("policy_count")
                     ),
                     kpi = TRUE
  ),
  kpi2 = custom_card("gov_pol_count",
                     "Government Policies",
                     div(
                       class = "card_metric",
                       uiOutput("gov_pol_count")
                     ),
                     kpi = TRUE
  ),
  kpi3 = custom_card("Non_gov_pol_count",
                     "Divestments",
                     div(
                       class = "card_metric",
                       uiOutput("Non_gov_pol_count")
                     ),
                     kpi = TRUE
  ),
  kpi7 = custom_card("ffnpt_total_count",
                     "Treaty Endorsements",
                     div(
                       class = "card_metric",
                       uiOutput("ffnpt_total_count")
                     ),
                     kpi = TRUE
  ),
  map = custom_card("policy_map",
                    "Policy Map (click on a country for more information)",
                    leafletOutput("mymap", width="100%", height="100%")
  ),
  dropdown = shiny::selectInput(inputId = "Country",
                                label = "Select a country for more details",
                                choices = c("", sort(unique(country_overview_large$Country))),
                                selected = c("United Kingdom"),
                                multiple = FALSE
  ),
  country_title = uiOutput("country_title"),
  card1 = custom_card("details_policy",
                      "Policy Details",
                      policy_card_content
  ),
  card2 = custom_card("details_policy_sources",
                      "Policy Sources",
                      policy_sources_card_content
  ),
  card3 = custom_card("details_fossil",
                      "Fossil Fuel Profiles",
                      fossil_card_content
  )
)




