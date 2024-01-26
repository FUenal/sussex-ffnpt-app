### SHINY SERVER ###

server = function(input, output, session) {
    #init country reactive
    all_countries <- sort(unique(country_overview_large$Country))
    reactive_country <- reactiveVal("United Kingdom")
    #catch tooltip strong element and make binding
    observeEvent(input$mymap_shape_click, {
      runjs('
        my_country = $(".leaflet-tooltip").parent().find("strong:first").text();
        Shiny.setInputValue("Country", my_country)
      ')
    })
    #update country reactive only for accepted values
    observeEvent(input$Country, {
      req(input$Country %in% all_countries)

      #Update the dropdown value when the update is triggered from the map
      updateSelectizeInput(session, "Country", selected = input$Country)
      # Updates the map when the dropdown value is updated via the dropdown
      runjs(paste0("active_country = '", input$Country, "'; set_default_selected_country();"))

      reactive_country(input$Country)
    })

    output$mymap <- renderLeaflet({
        basemap
    })

    observeEvent(input$tab_country_profiles, {

      output$country_title <- renderUI({
        h2(reactive_country(), style = "border-bottom: 3px solid; padding-top: 50px;")
      })

      output$policy_count <- renderUI({
        paste0(sum(country_overview_large$Policy_total))
      })
      output$gov_pol_count <- renderUI({
        paste0(prettyNum(sum(country_overview_large$Government_policies_total), big.mark=","))
      })
      output$Non_gov_pol_count <- renderUI({
        paste0(prettyNum(sum(country_overview_large$Divestment_total), big.mark=","))
      })
      output$ffnpt_total_count <- renderUI({
        paste0(prettyNum(sum(country_overview_large$treaty_total), big.mark=","))
      })      
    })

    observeEvent(input$tab_download, {
      output$mbl_count1 <- renderUI({
        paste0(prettyNum(sum(country_overview_large$Moratoria_bans_limits_total), big.mark=","))
      })
      output$sr_count1 <- renderUI({
        paste0(prettyNum(sum(country_overview_large$Subsidy_removal_total), big.mark=","))
      })
      output$div_count1 <- renderUI({
        paste0(prettyNum(sum(country_overview_large$Divestment_total), big.mark=","))
      })
    })
    
    observeEvent(input$tab_policy_overview, {
      output$mbl_count <- renderUI({
        paste0(prettyNum(sum(country_overview_large$Moratoria_bans_limits_total), big.mark=","))
      })
      output$sr_count <- renderUI({
        paste0(prettyNum(sum(country_overview_large$Subsidy_removal_total), big.mark=","))
      })
      output$div_count <- renderUI({
        paste0(prettyNum(sum(country_overview_large$Divestment_total), big.mark=","))
      })

      output$cumulative_mbl_plot <- renderHighchart({
          moratoria_bans_limits %>%
              group_by(date) %>%
              filter(date <= "2022-01-01") %>% 
              summarise(n = sum(Policy)) %>%
              hchart(., 'column', hcaes(x = date, y = n)) %>%
              hc_exporting(enabled = TRUE) %>%
              hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                         shared = TRUE, borderWidth = 2) %>%
              hc_title(text="Moratoria, Bans & Limits Across Time",
                       style = list(fontWeight = "bold", fontSize = "20px"),
                       align="center") %>%
              # hc_subtitle(text="Data Source: FFNPT Database",
              #             style = list(fontWeight = "bold", fontSize = "13px"),
              #             align="center") %>%
              hc_tooltip(
                  headerFormat = "",
                  pointFormat = "Moratorial, Bans & Limits: <b>{point.n:.2f}</b>"
              ) %>%
              hc_add_theme(hc_theme_elementary()) %>%
              hc_colors("#253550") %>%
              hc_xAxis(visible = TRUE, title = list(text = "Year"),
                       style = list(fontWeight = "bold", fontSize = "15px")) %>%
              hc_yAxis(visible = TRUE, title = list(text = "Number of Moratoria, Bans & Limits"),
                       style = list(fontWeight = "bold", fontSize = "15px")) %>%
              hc_plotOptions(series = list(boderWidth = 0,
                                           dataLabels = list(enabled = TRUE)
              ))
      })

      output$cumulative_div_plot <- renderHighchart({
          divestment_new %>%
              group_by(date) %>%
              filter(date <= "2022-01-01") %>% 
              summarise(n = sum(Policy)) %>%
              hchart(., 'column', hcaes(x = date, y = n)) %>%
              hc_exporting(enabled = TRUE) %>%
              hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                         shared = TRUE, borderWidth = 2) %>%
              hc_title(text="Divestments Across Time",
                       style = list(fontWeight = "bold", fontSize = "20px"),
                       align="center") %>%
              # hc_subtitle(text="Data Source: FFNPT Database",
              #             style = list(fontWeight = "bold", fontSize = "13px"),
              #             align="center") %>%
              hc_tooltip(
                  headerFormat = "",
                  pointFormat = "Divestments: <b>{point.n:.2f}</b>"
              ) %>%
              hc_add_theme(hc_theme_elementary()) %>%
              hc_colors("#FF9100") %>%
              hc_xAxis(visible = TRUE, title = list(text = "Year"),
                       style = list(fontWeight = "bold", fontSize = "15px")) %>%
              hc_yAxis(visible = TRUE, title = list(text = "Number of Divestments"),
                       style = list(fontWeight = "bold", fontSize = "15px")) %>%
              hc_plotOptions(series = list(boderWidth = 0,
                                           dataLabels = list(enabled = TRUE)
              ))
      })

      output$cumulative_sr_plot <- renderHighchart({
          subsidy_removal %>%
              group_by(date) %>%
              filter(date <= "2022-01-01") %>% 
              summarise(n = sum(Policy)) %>%
              hchart(., 'column', hcaes(x = date, y = n)) %>%
              hc_exporting(enabled = TRUE) %>%
              hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                         shared = TRUE, borderWidth = 2) %>%
              hc_title(text="Subsidy-Reductions Across Time",
                       style = list(fontWeight = "bold", fontSize = "20px"),
                       align="center") %>%
              # hc_subtitle(text="Data Source: FFNPT Database",
              #             style = list(fontWeight = "bold", fontSize = "13px"),
              #             align="center") %>%
              hc_tooltip(
                  headerFormat = "",
                  pointFormat = "Subdisy-Reductions: <b>{point.n:.2f}</b>"
              ) %>%
              hc_add_theme(hc_theme_elementary()) %>%
              hc_colors("#0C101E") %>%
              hc_xAxis(visible = TRUE, title = list(text = "Year"),
                       style = list(fontWeight = "bold", fontSize = "15px")) %>%
              hc_yAxis(visible = TRUE, title = list(text = "Number of Subsidy-Reductions"),
                       style = list(fontWeight = "bold", fontSize = "15px")) %>%
              hc_plotOptions(series = list(boderWidth = 0,
                                           dataLabels = list(enabled = TRUE)
              ))
      })
    })

    observeEvent(input$tab_commitments_type, {
      output$pol_plot_5 <- renderHighchart ({

        req(reactive_country())

        # Set highcharter options
        options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))
        # colors <- c("#253550", "#FF9100", "#99B1C3")
        colors <- c("#FF9100", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d")
        #colors2 <- c("#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D", "#FCFDBF")

        # Filter data
        dff <- country_overview_large %>% filter(Country==reactive_country())
        dff_5 <- select(dff, c("MBL_Type_Oil", "MBL_Type_Gas", "MBL_Type_Coal", "MBL_Type_Offshore", "MBL_Type_Oil_Gas", "MBL_Type_Oil_Gas_Coal",
                               "MBL_Type_Coal_Gas", "MBL_Type_All", "MBL_Type_Ore")) %>%
          rename("Oil" = "MBL_Type_Oil", "Gas" = "MBL_Type_Gas", "Coal" = "MBL_Type_Coal", "Offshore" = "MBL_Type_Offshore",
                 "Oil & Gas" = "MBL_Type_Oil_Gas", "Oil, Gas & Coal" = "MBL_Type_Oil_Gas_Coal", "Coal & Gas" = "MBL_Type_Coal_Gas",
                 "All" = "MBL_Type_All", "Ore" = "MBL_Type_Ore")
        dff_5 = dff_5[,-1]

        # save columns names as vector
        names <- colnames(dff_5)

        # transpose
        df_transposed_4 <- transpose(dff_5)
        rownames(df_transposed_4) <- colnames(dff_5)

        # add column names as column
        df_transposed_4$names <- names

        #plotting the data
        hchart(df_transposed_4, "pie", hcaes(x=names, y=V1), name = ':') %>%
          hc_exporting(enabled = TRUE) %>%
          hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                     shared = TRUE, borderWidth = 2) %>%
          hc_title(text="MBL: Fossil Fuel Types",align="center") %>%
          # hc_subtitle(text="Data Source: FFNPT Database",align="center") %>%
          hc_add_theme(hc_theme_elementary()) %>%
          hc_colors(colors) %>%
          hc_plotOptions(
            series = list(
              showInLegend = TRUE,
              dataLabels = list(
                enabled = TRUE,
                distance = -30,
                format = "<b>{point.V1}</b>",
                color = '#FFFFFF'
              )
            )
          )
      })

      output$pol_plot_7 <- renderHighchart ({

        req(reactive_country())

        # Set highcharter options
        options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))
        # colors <- c("#253550", "#FF9100", "#99B1C3")
        colors <- c("#FF9100", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d")
        #colors2 <- c("#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D", "#FCFDBF")

        # Filter data
        dff <- country_overview_large %>% filter(Country==reactive_country())
        dff_7 <- select(dff, c("Div_Type_Full", "Div_Type_Partial", "Div_Type_Fossil_Free", "Div_Type_Coal_Only", "Div_Type_Coal_and_Tar_Sands_Only")) %>%
          rename("Full"  = "Div_Type_Full", "Partial" = "Div_Type_Partial", "Fossil Free" = "Div_Type_Fossil_Free",
                 "Coal" = "Div_Type_Coal_Only", "Coal & Tar Sands" = "Div_Type_Coal_and_Tar_Sands_Only")
        dff_7 = dff_7[,-1]

        # save columns names as vector
        names <- colnames(dff_7)

        # transpose
        df_transposed_6 <- transpose(dff_7)
        rownames(df_transposed_6) <- colnames(dff_7)

        # add column names as column
        df_transposed_6$names <- names

        #plotting the data
        hchart(df_transposed_6, "pie", hcaes(x=names, y=V1), name = ':') %>%
          hc_exporting(enabled = TRUE) %>%
          hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                     shared = TRUE, borderWidth = 2) %>%
          hc_title(text="Divestment: Fossil Fuel Type",align="center") %>%
          # hc_subtitle(text="Data Source: FFNPT Database",align="center") %>%
          hc_add_theme(hc_theme_elementary()) %>%
          hc_colors(colors) %>%
          hc_plotOptions(
            series = list(
              showInLegend = TRUE,
              dataLabels = list(
                enabled = TRUE,
                distance = -30,
                format = "<b>{point.V1}</b>",
                color = '#FFFFFF'
              )
            )
          )
      })

      output$pol_plot_9 <- renderHighchart ({

        req(reactive_country())

        # Set highcharter options
        options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))
        # colors <- c("#253550", "#FF9100", "#99B1C3")
        colors <- c("#FF9100", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d")
        #colors2 <- c("#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D", "#FCFDBF")

        # Filter data
        dff <- country_overview_large %>% filter(Country==reactive_country())
        dff_9 <- select(dff, c("Sr_Type_All", "Sr_Type_Coal", "Sr_Type_Gas", "Sr_Type_Oil", "Sr_Type_Oil_Gas", "Sr_Type_Oil_Coal", "Sr_Type_Gas_Coal")) %>%
          rename("All"  = "Sr_Type_All", "Coal" = "Sr_Type_Coal", "Gas" = "Sr_Type_Gas", "Oil" = "Sr_Type_Oil", "Oil & Gas" = "Sr_Type_Oil_Gas",
                 "Oil & Coal" = "Sr_Type_Oil_Coal", "Gas & Coal" = "Sr_Type_Gas_Coal")
        dff_9 = dff_9[,-1]

        # save columns names as vector
        names <- colnames(dff_9)

        # transpose
        df_transposed_8 <- transpose(dff_9)
        rownames(df_transposed_8) <- colnames(dff_9)

        # add column names as column
        df_transposed_8$names <- names

        #plotting the data
        hchart(df_transposed_8, "pie", hcaes(x=names, y=V1), name = ':') %>%
          hc_exporting(enabled = TRUE) %>%
          hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                     shared = TRUE, borderWidth = 2) %>%
          hc_title(text="Subsidy-Reduction: Fossil Fuel Type",align="center") %>%
          # hc_subtitle(text="Data Source: FFNPT Database",align="center") %>%
          hc_add_theme(hc_theme_elementary()) %>%
          hc_colors(colors) %>%
          hc_plotOptions(
            series = list(
              showInLegend = TRUE,
              dataLabels = list(
                enabled = TRUE,
                distance = -30,
                format = "<b>{point.V1}</b>",
                color = '#FFFFFF'
              )
            )
          )
      })
    })

    observeEvent(input$tab_commitments_level, {

          output$pol_plot_4 <- renderHighchart ({

            req(reactive_country())

            # Set highcharter options
            options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))
            # colors <- c("#253550", "#FF9100", "#99B1C3")
            colors <- c("#FF9100", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d")
            #colors2 <- c("#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D", "#FCFDBF")

            # Filter data
            dff <- country_overview_large %>% filter(Country==reactive_country())
            dff_4 <- select(dff, c("MBL_Class_Moratorium", "MBL_Class_Ban", "MBL_Class_Partial_Ban", "MBL_Class_Limitation")) %>%
              rename("Moratoria" = "MBL_Class_Moratorium", "Ban" = "MBL_Class_Ban", "Partial Ban" = "MBL_Class_Partial_Ban", "Limitation" = "MBL_Class_Limitation")
            dff_4 = dff_4[,-1]

            # save columns names as vector
            names <- colnames(dff_4)

            # transpose
            df_transposed_3 <- transpose(dff_4)
            rownames(df_transposed_3) <- colnames(dff_4)

            # add column names as column
            df_transposed_3$names <- names

            #plotting the data
            hc <- hchart(df_transposed_3, "pie", hcaes(x=names, y=V1), name = ':') %>%
              hc_exporting(enabled = TRUE) %>%
              hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5") %>%
              hc_title(text="MBL: Type",align="center") %>%
              # hc_subtitle(text="Data Source: FFNPT Database",align="center") %>%
              hc_add_theme(hc_theme_elementary()) %>%
              hc_colors(colors) %>%
              hc_legend(align = "left") %>%
              hc_plotOptions(
                series = list(
                  showInLegend = TRUE,
                  dataLabels = list(
                    enabled = TRUE,
                    distance = -30,
                    format = "<b>{point.V1}</b>",
                    color = '#FFFFFF'
                  )
                )
              )
          })


          output$pol_plot_6 <- renderHighchart ({

            req(reactive_country())

            # Set highcharter options
            options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))
            # colors <- c("#253550", "#FF9100", "#99B1C3")
            colors <- c("#FF9100", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d")
            #colors2 <- c("#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D", "#FCFDBF")

            # Filter data
            dff <- country_overview_large %>% filter(Country==reactive_country())
            dff_6 <- select(dff, c("mbl_country", "mbl_city_region")) %>%
              rename("Moratoria, bans, & limits (Country-level)" = "mbl_country", "Moratoria, bans, & limits (City/Region level)" = "mbl_city_region")
            dff_6 = dff_6[,-1]

            # save columns names as vector
            names <- colnames(dff_6)

            # transpose
            df_transposed_5 <- transpose(dff_6)
            rownames(df_transposed_5) <- colnames(dff_6)

            # add column names as column
            df_transposed_5$names <- names

            #plotting the data
            hchart(df_transposed_5, "pie", hcaes(x=names, y=V1), name = ':') %>%
              hc_exporting(enabled = TRUE) %>%
              hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                         shared = TRUE, borderWidth = 2) %>%
              hc_title(text="MBL: National & Subnational Levels",align="center") %>%
              # hc_subtitle(text="Data Source: FFNPT Database",align="center") %>%
              hc_add_theme(hc_theme_elementary()) %>%
              hc_colors(colors) %>%
              hc_plotOptions(
                series = list(
                  showInLegend = TRUE,
                  dataLabels = list(
                    enabled = TRUE,
                    distance = -30,
                    format = "<b>{point.V1}</b>",
                    color = '#FFFFFF'
                  )
                )
              )
          })



          output$pol_plot_8 <- renderHighchart ({

            req(reactive_country())

            # Set highcharter options
            options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))
            # colors <- c("#253550", "#FF9100", "#99B1C3")
            colors <- c("#FF9100", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d")
            #colors2 <- c("#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D", "#FCFDBF")

            # Filter data
            dff <- country_overview_large %>% filter(Country==reactive_country())
            dff_8 <- select(dff, c("Div_Orga_NGO", "Div_Orga_Pension_Fund", "Div_Orga_For_Profit_Corporation", "Div_Orga_Philanthropic_Foundation",
                                   "Div_Orga_Government", "Div_Orga_Educational_Institution", "Div_Orga_Healthcare_Institution",
                                   "Div_Orga_Cultural_Institution", "Div_Orga_Other")) %>%
              rename("NGO"  = "Div_Orga_NGO", "Pension Fund" = "Div_Orga_Pension_Fund", "For Profit Corporation" = "Div_Orga_For_Profit_Corporation",
                     "Philanthropic Foundation" = "Div_Orga_Philanthropic_Foundation", "Government" = "Div_Orga_Government",
                     "Educational Institution" = "Div_Orga_Educational_Institution", "Healthcare Institution" = "Div_Orga_Healthcare_Institution",
                     "Cultural Institution" = "Div_Orga_Cultural_Institution", "Other" = "Div_Orga_Other")
            dff_8 = dff_8[,-1]

            # save columns names as vector
            names <- colnames(dff_8)

            # transpose
            df_transposed_7 <- transpose(dff_8)
            rownames(df_transposed_7) <- colnames(dff_8)

            # add column names as column
            df_transposed_7$names <- names

            #plotting the data
            hchart(df_transposed_7, "pie", hcaes(x=names, y=V1), name = ':') %>%
              hc_exporting(enabled = TRUE) %>%
              hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                         shared = TRUE, borderWidth = 2) %>%
              hc_title(text="Divestment: Type of Organization",align="center") %>%
              # hc_subtitle(text="Data Source: FFNPT Database",align="center") %>%
              hc_add_theme(hc_theme_elementary()) %>%
              hc_colors(colors) %>%
              hc_plotOptions(
                series = list(
                  showInLegend = TRUE,
                  dataLabels = list(
                    enabled = TRUE,
                    distance = -30,
                    format = "<b>{point.V1}</b>",
                    color = '#FFFFFF'
                  )
                )
              )
          })
    })

    # Finds links in a string and replaces them with a HTML link
    parseURL <- function(content) {
      separator <- ", "
      
      lapply(content, function(entry) {
        parts <- strsplit(entry, separator)[[1]]
        
        lapply(parts, function(part) {
          if (startsWith(part, "http")) {
            part <- paste0("<a target='_blank' href='", part, "'>", part, "</a>")
          }
          
          part
        }) %>% paste(collapse = separator)
      })
    }
    
    observeEvent(input$tab_sources_mlb, {
      output$dataTable1 <- DT::renderDataTable(server = FALSE, DT::datatable({
        moratoria_bans_limitsDF <- moratoria_bans_limits[moratoria_bans_limits$Country == reactive_country(), ]
        moratoria_bans_limitsDF %>%
            group_by(City_state_or_province) %>%
            select(c("City_state_or_province", "Category", "Fuel_type", "Fuel_subtype", "Start", "End", "Sources_and_more_info")) %>%
            mutate(Sources_and_more_info = parseURL(Sources_and_more_info)) %>%
            rename("Jurisdiction" = "City_state_or_province",  "Fuel type" = "Fuel_type", "Fuel subtype" = "Fuel_subtype", "Sources" = "Sources_and_more_info") %>%
          # mutate(Sources = sprintf(paste0('<a href="', moratoria_bans_limitsDF$Sources,'" target="_blank" class="btn btn-primary">Link</a>'))) %>% 
          replace(is.na(.), "No entries") 
      },
      extensions = 'Buttons',
      filter = list(position = 'top', clear = FALSE, plain = TRUE),
      options = list(
        paging = TRUE,
        scrollX=TRUE, 
        searching = TRUE,
        ordering = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel'),
        pageLength=5, 
        lengthMenu=c(3,5,10)
      ),
      escape = FALSE,
      class = "display"))
    })


    observeEvent(input$tab_sources_sr, {
      output$dataTable2 <- DT::renderDataTable(server = FALSE, DT::datatable({
        subsidy_removalDF <- subsidy_removal[subsidy_removal$Country == reactive_country(), ]
        subsidy_removalDF %>%
            group_by(Country) %>%
            select(c("Country", "Category", "Fuel_type", "Fuel_subtype", "Start", "Sources_and_more_info")) %>% # "Description",
            mutate(Sources_and_more_info = parseURL(Sources_and_more_info)) %>%
            rename("Jurisdiction" = "Country", "Fuel type" = "Fuel_type", "Fuel subtype" = "Fuel_subtype", "Sources" = "Sources_and_more_info") %>%
            replace(is.na(.), "No entries")
      },
      extensions = 'Buttons',
      filter = list(position = 'top', clear = FALSE, plain = TRUE),
      options = list(
        paging = TRUE,
        scrollX=TRUE, 
        searching = TRUE,
        ordering = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel'),
        pageLength=5, 
        lengthMenu=c(3,5,10)
      ),
      escape = FALSE,
      class = "display"))
    })


    observeEvent(input$tab_sources_div, {
      output$dataTable3 <- DT::renderDataTable(server = FALSE, DT::datatable({
        divestmentDFN <- divestment_new[divestment_new$Country == reactive_country(), ]
        divestmentDFN %>%
            group_by(Country) %>%
            select(c("Country", "City", "Type", "Organisation", "Organisation_type", "Sources_and_more_info")) %>%
            # mutate(Sources_and_more_info = parseURL(Sources_and_more_info)) %>%
            rename("Jurisdiction" = "Country", "Organisation type" = "Organisation_type", "Sources" = "Sources_and_more_info" ) %>%
            replace(is.na(.), "No entries")
      },
      extensions = 'Buttons',
      filter = list(position = 'top', clear = FALSE, plain = TRUE),
      options = list(
        paging = TRUE,
        scrollX=TRUE, 
        searching = TRUE,
        ordering = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel'),
        pageLength=5, 
        lengthMenu=c(3,5,10)
      ),
      escape = FALSE,
      class = "display"))
    })
    
    observeEvent(input$tab_download, {
      output$dataTable4 <- DT::renderDataTable(server=FALSE, DT::datatable({
        moratoria_bans_limitsDF1 <- moratoria_bans_limits
        moratoria_bans_limitsDF1 %>%
          group_by(City_state_or_province) %>%
          select(c("City_state_or_province", "Category", "Fuel_type", "Fuel_subtype", "Sources_and_more_info")) %>% # "Start", "End",
          mutate(Sources_and_more_info = parseURL(Sources_and_more_info)) %>%
          rename("Jurisdiction" = "City_state_or_province",  "Fuel type" = "Fuel_type", "Fuel subtype" = "Fuel_subtype", "Sources" = "Sources_and_more_info") %>%
          # mutate(Sources = sprintf(paste0('<a href="', moratoria_bans_limits$Sources,'" target="_blank" class="btn btn-primary">Link</a>'))) %>% 
          replace(is.na(.), "---") 
      },
      extensions = 'Buttons',
      filter = list(position = 'top', clear = FALSE, plain = TRUE),
      options = list(
        paging = TRUE,
        scrollX=TRUE, 
        searching = TRUE,
        ordering = TRUE,
        fixedColumns = TRUE, 
        autoWidth = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel'),
        pageLength=5, 
        lengthMenu=c(5,10,15)
      ),
      escape = FALSE,
      class = "display"))
    })
    
    
    observeEvent(input$tab_download, {
      output$dataTable5 <- DT::renderDataTable(server=FALSE, DT::datatable({
        subsidy_removalDF1 <- subsidy_removal
        subsidy_removalDF1 %>%
          group_by(Country) %>%
          select(c("Country", "Category", "Fuel_type", "Fuel_subtype", "Start", "Sources_and_more_info")) %>% # "Description",
          #mutate(Sources_and_more_info = parseURL(Sources_and_more_info)) %>%
          rename("Jurisdiction" = "Country", "Fuel type" = "Fuel_type", "Fuel subtype" = "Fuel_subtype", "Sources" = "Sources_and_more_info") %>%
          replace(is.na(.), "---")
      },
      extensions = 'Buttons',
      filter = list(position = 'top', clear = FALSE, plain = TRUE),
      options = list(
        paging = TRUE,
        scrollX=TRUE, 
        searching = TRUE,
        ordering = TRUE,
        fixedColumns = TRUE, 
        autoWidth = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel'),
        pageLength=5, 
        lengthMenu=c(5,10,15)
      ),
      escape = FALSE,
      class = "display"))
    })
    
    
    observeEvent(input$tab_download, {
      output$dataTable6 <- DT::renderDataTable(server=FALSE, DT::datatable({
        divestmentDFN1 <- divestment_new
        divestmentDFN1 %>%
          group_by(Country) %>%
          select(c("Country", "City", "Type", "Organisation", "Organisation_type", "Sources_and_more_info")) %>%
          # mutate(Sources_and_more_info = parseURL(Sources_and_more_info)) %>%
          rename("Jurisdiction" = "Country", "Organisation type" = "Organisation_type", "Sources" = "Sources_and_more_info") %>%
          replace(is.na(.), "---")
      },
      extensions = 'Buttons',
      filter = list(position = 'top', clear = FALSE, plain = TRUE),
      options = list(
        paging = TRUE,
        scrollX=TRUE, 
        searching = TRUE,
        ordering = TRUE,
        fixedColumns = TRUE, 
        autoWidth = TRUE,
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel'),
        pageLength=5, 
        lengthMenu=c(5,10,15)
      ),
      escape = FALSE,
      class = "display"))
    })
    

    observeEvent(input$tab_ffp, {
      # # country-specific plots
      output$coal_plot_x <- renderHighchart ({

          req(reactive_country())

          # Set highcharter options
          options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))

          df <- fossil_fuel_production %>% filter(Entity==reactive_country())#making is the dataframe of the country

          #plotting the data
          hchart(df, "column", hcaes(x=Year,y=Coal.production..TWh., group = Entity))  %>%
              hc_exporting(enabled = TRUE) %>%
              hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                         shared = TRUE, borderWidth = 2) %>%
              hc_title(text="Coal production over time",align="center") %>%
              hc_subtitle(text="Data Source: BP Statistical Review of World Energy & SHIFT Data Portal",align="center") %>%
              hc_add_theme(hc_theme_elementary()) %>%
              hc_colors("#2c3e50")
      })

      output$gas_plot_x <- renderHighchart ({

          req(reactive_country())

          # Set highcharter options
          options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))

          df <- fossil_fuel_production %>% filter(Entity==reactive_country())

          #plotting the data
          hchart(df, "column", hcaes(x=Year,y=Gas.production..TWh., group = Entity))  %>%

              hc_exporting(enabled = TRUE) %>%
              hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                         shared = TRUE, borderWidth = 2) %>%
              hc_title(text="Gas production over time",align="center") %>%
              hc_subtitle(text="Data Source: Statistical Review of World Energy",align="center") %>%
              hc_add_theme(hc_theme_elementary()) %>%
              hc_colors("#7f8c8d")

      })

      output$oil_plot_x <- renderHighchart ({

         req(reactive_country())

         # Set highcharter options
          options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))

          df <- fossil_fuel_production %>% filter(Entity==reactive_country())

          #plotting the data
          hchart(df, "column", hcaes(x=Year,y=Oil.production..TWh., group = Entity))  %>%

              hc_exporting(enabled = TRUE) %>%
              hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                         shared = TRUE, borderWidth = 2) %>%
              hc_title(text="Oil production over time",align="center") %>%
              hc_subtitle(text="Data Source: BP Statistical Review of World Energy & SHIFT Data Portal",align="center") %>%
              hc_add_theme(hc_theme_elementary()) %>%
              hc_colors("#253551")
      })

    })

    observeEvent(input$tab_coeo, {
      output$oil_co2_plot_x <- renderHighchart ({

        req(reactive_country())

        # Set highcharter options
        options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))

        df <- co2_oil_annual %>% filter(Entity==reactive_country())

        #plotting the data
        hchart(df, "column", hcaes(x=Year,y=Annual.CO2.emissions.from.oil, group = Entity))  %>%

          hc_exporting(enabled = TRUE) %>%
          hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                     shared = TRUE, borderWidth = 2) %>%
          hc_title(text="CO2 emission from oil over time",align="center") %>%
          hc_subtitle(text="Data Source: Global Carbon Project",align="center") %>%
          hc_add_theme(hc_theme_elementary()) %>%
          hc_colors("#253551")
      })
    })

    observeEvent(input$tab_coeg, {
      output$gas_co2_plot_x <- renderHighchart ({

        req(reactive_country())

        # Set highcharter options
        options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))

        df <- co2_gas_annual %>% filter(Entity==reactive_country())

        #plotting the data
        hchart(df, "column", hcaes(x=Year,y=Annual.CO2.emissions.from.gas, group = Entity))  %>%

          hc_exporting(enabled = TRUE) %>%
          hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                     shared = TRUE, borderWidth = 2) %>%
          hc_title(text="CO2 emission from gas over time",align="center") %>%
          hc_subtitle(text="Data Source: Global Carbon Project",align="center") %>%
          hc_add_theme(hc_theme_elementary()) %>%
          hc_colors("#253551")
      })
    })

    observeEvent(input$tab_coec, {
      output$coal_co2_plot_x <- renderHighchart ({

        req(reactive_country())

        # Set highcharter options
        options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))

        df <- co2_coal_annual %>% filter(Entity==reactive_country())

        #plotting the data
        hchart(df, "column", hcaes(x=Year,y=Annual.CO2.emissions.from.coal, group = Entity))  %>%

          hc_exporting(enabled = TRUE) %>%
          hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5",
                     shared = TRUE, borderWidth = 2) %>%
          hc_title(text="CO2 emission from coal over time",align="center") %>%
          hc_subtitle(text="Data Source: Global Carbon Project",align="center") %>%
          hc_add_theme(hc_theme_elementary()) %>%
          hc_colors("#253551")
      })
    })








    # outputOptions(output, "coal_plot_x", suspendWhenHidden = FALSE)
    # outputOptions(output, "gas_plot_x", suspendWhenHidden = FALSE)
    # outputOptions(output, "oil_plot_x", suspendWhenHidden = FALSE)
    # outputOptions(output, "oil_co2_plot_x", suspendWhenHidden = FALSE)
    # outputOptions(output, "gas_co2_plot_x", suspendWhenHidden = FALSE)
    # outputOptions(output, "coal_co2_plot_x", suspendWhenHidden = FALSE)
    #
    # output$pol_plot_1 <- renderHighchart ({
    #
    #     req(reactive_country())
    #
    #     # Set highcharter options
    #     options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))
    #     colors <- c("#253550", "#FF9100", "#99B1C3")
    #     #colors <- c("#FF9100", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d")
    #     #colors2 <- c("#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D", "#FCFDBF")
    #
    #     # Filter data
    #     dff <- country_overview_large %>% filter(Country==reactive_country())
    #     dff_1 <- select(dff, c("Government_policies_total", "Non_Government_policies_total")) %>%
    #         rename("Policies" = "Government_policies_total", "Divestments" = "Non_Government_policies_total")
    #     dff_1 = dff_1[,-1]
    #
    #     # save columns names as vector
    #     names <- colnames(dff_1)
    #
    #     # transpose
    #     df_transposed <- transpose(dff_1)
    #     rownames(df_transposed) <- colnames(dff_1)
    #
    #     # add column names as column
    #     df_transposed$names <- names
    #
    #     #plotting the data
    #     hchart(df_transposed, "pie", hcaes(x=names, y=V1), name = ':') %>%
    #
    #         hc_exporting(enabled = TRUE) %>%
    #         hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5") %>%
    #         hc_title(text="Policies & Divestments",align="center") %>%
    #         # hc_subtitle(text="Data Source: FFNPT Database",align="center") %>%
    #         hc_add_theme(hc_theme_elementary()) %>%
    #         hc_colors(colors) %>%
    #         hc_legend(align = "left") %>%
    #         hc_plotOptions(
    #             series = list(
    #               showInLegend = TRUE,
    #                 dataLabels = list(
    #                     enabled = TRUE,
    #                     distance = -30,
    #                     format = "<b>{point.V1}</b>",
    #                     color = '#FFFFFF'
    #                 )
    #             )
    #         )
    # })
    #
    # output$pol_plot_2 <- renderHighchart ({
    #
    #     req(reactive_country())
    #
    #     # Set highcharter options
    #     options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))
    #     colors <- c("#253550", "#FF9100", "#99B1C3")
    #     #colors <- c("#FF9100", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d")
    #     #colors2 <- c("#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D", "#FCFDBF")
    #
    #     # Filter data
    #     dff <- country_overview_large %>% filter(Country==reactive_country())
    #     dff_2 <- select(dff, c("Moratoria_bans_limits", "Subsidy_removal", "Divestment")) %>%
    #         rename("Moratoria, bans, & limits" = "Moratoria_bans_limits", "Subsidy removals" = "Subsidy_removal", "Divestments" = "Divestment")
    #     dff_2 = dff_2[,-1]
    #
    #     # save columns names as vector
    #     names <- colnames(dff_2)
    #
    #     # transpose
    #     df_transposed_1 <- transpose(dff_2)
    #     rownames(df_transposed_1) <- colnames(dff_2)
    #
    #     # add column names as column
    #     df_transposed_1$names <- names
    #
    #     #plotting the data
    #     hchart(df_transposed_1, "pie", hcaes(x=names, y=V1), name = ':') %>%
    #
    #         hc_exporting(enabled = TRUE) %>%
    #         hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5") %>%
    #         hc_title(text="Policy Types",align="center") %>%
    #         # hc_subtitle(text="Data Source: FFNPT Database",align="center") %>%
    #         hc_add_theme(hc_theme_elementary()) %>%
    #         hc_colors(colors) %>%
    #         hc_legend(align = "left") %>%
    #       hc_plotOptions(
    #         series = list(
    #           showInLegend = TRUE,
    #           dataLabels = list(
    #             enabled = TRUE,
    #             distance = -30,
    #             format = "<b>{point.V1}</b>",
    #             color = '#FFFFFF'
    #           )
    #         )
    #       )
    # })
    #
    # output$pol_plot_3 <- renderHighchart ({
    #
    #     req(reactive_country())
    #
    #     # Set highcharter options
    #     options(highcharter.theme = hc_theme_smpl(tooltip = list(valueDecimals = 2)))
    #     colors <- c("#253550", "#FF9100", "#99B1C3")
    #     #colors <- c("#FF9100", "#2980b9", "#2ecc71", "#f1c40f", "#2c3e50", "#7f8c8d")
    #     #colors2 <- c("#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D", "#FCFDBF")
    #
    #     # Filter data
    #     dff <- country_overview_large %>% filter(Country==reactive_country())
    #     dff_3 <- select(dff, c("mbl_country", "mbl_city_region", "divestment_city_region")) %>%
    #         rename("Moratoria, bans, & limits (Country-level)" = "mbl_country", "Moratoria, bans, & limits (City/Region level)" = "mbl_city_region",
    #                "Divestments (City/Region level)" = "divestment_city_region")
    #     dff_3 = dff_3[,-1]
    #
    #     # save columns names as vector
    #     names <- colnames(dff_3)
    #
    #     # transpose
    #     df_transposed_2 <- transpose(dff_3)
    #     rownames(df_transposed_2) <- colnames(dff_3)
    #
    #     # add column names as column
    #     df_transposed_2$names <- names
    #
    #     #plotting the data
    #     hchart(df_transposed_2, "pie", hcaes(x=names, y=V1), name = ':') %>%
    #         hc_exporting(enabled = TRUE) %>%
    #         hc_tooltip(crosshairs = TRUE, backgroundColor = "#FCFFC5") %>%
    #         hc_title(text="Policies across sectors & levels",align="center") %>%
    #         # hc_subtitle(text="Data Source: FFNPT Database",align="center") %>%
    #         hc_add_theme(hc_theme_elementary()) %>%
    #         hc_colors(colors) %>%
    #         hc_legend(align = "left") %>%
    #       hc_plotOptions(
    #         series = list(
    #           showInLegend = TRUE,
    #           dataLabels = list(
    #             enabled = TRUE,
    #             distance = -30,
    #             format = "<b>{point.V1}</b>",
    #             color = '#FFFFFF'
    #           )
    #         )
    #       )
    # })
    #

    # outputOptions(output, "pol_plot_1", suspendWhenHidden = FALSE)
    # outputOptions(output, "pol_plot_2", suspendWhenHidden = FALSE)
    # outputOptions(output, "pol_plot_3", suspendWhenHidden = FALSE)
    # outputOptions(output, "pol_plot_4", suspendWhenHidden = FALSE)
    # outputOptions(output, "pol_plot_5", suspendWhenHidden = FALSE)
    # outputOptions(output, "pol_plot_6", suspendWhenHidden = FALSE)
    # outputOptions(output, "pol_plot_7", suspendWhenHidden = FALSE)
    # outputOptions(output, "pol_plot_8", suspendWhenHidden = FALSE)
    # outputOptions(output, "pol_plot_9", suspendWhenHidden = FALSE)
    #
    #
    #
    #
    #
    #
    # outputOptions(output, "dataTable1", suspendWhenHidden = FALSE)
    # outputOptions(output, "dataTable2", suspendWhenHidden = FALSE)
    # outputOptions(output, "dataTable3", suspendWhenHidden = FALSE)

    # Grey out disable
    autoInvalidate <- reactiveTimer(10000)
    observe({
        autoInvalidate()
        cat(".")
    })

}
