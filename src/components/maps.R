baseMap <- function(baseGroups, overlayGroups) {
  leaflet(plot_map, options = leafletOptions(zoomControl = FALSE, attributionControl = FALSE)) %>%

    # Default map settings
    setView(15, 25, zoom = 2) %>%
    addTiles() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%

    # Adds controls for switching between layers
    # baseGroups are layers that only one can be active at the time
    # overlayGroups are layers that can be toggled on or off
    # Both should match the groups used with the addX functions group attribute
    addLayersControl(
      position = "bottomright",
      baseGroups = baseGroups,
      overlayGroups = overlayGroups,
      options = layersControlOptions(collapsed = FALSE, autoZIndex = TRUE)
    ) %>%

    # Last overlay group is the only active by default
    hideGroup(head(overlayGroups, -1)) %>%

    addMapPane("bases", zIndex = 410) %>%
    addMapPane("shapes", zIndex = 420) %>%

    # Adds a title to the layer control panel
    htmlwidgets::onRender("
        function() {
            $('.leaflet-control-layers-overlays')
              .prepend('<label style=\"text-align:center\"><strong>Policy Level/Type</strong><br/></label>');
            $('.leaflet-control-layers-base')
              .prepend('<label style=\"text-align:center\"><strong>Annual CO2 Emissions 2019</strong><br/></label>');
        }
    ") %>%

    # Adds a title to the layer control panel
    htmlwidgets::onRender("
        function() {
          set_default_selected_country()
        }
    ") %>%

    # Adds a zoom control
    htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this)
    }") %>%

    # Custom logic for toggling the base layer legends
    # Required as a workaround since the addLegend() function does not support grouping
    htmlwidgets::onRender("
       function(el, x) {
          updateLegend();
          this.on('baselayerchange', el => updateLegend());
       }"
    )
}

getTooltipStyles <- function(color) {
  return(list(
    padding = "3px 8px",
    `font-weight` = "bold",
    `font-family` = "Poppins",
    `color` = color,
    background = "white",
    `border-radius` = "10px",
    border = "none",
    `border-right` = paste(c("15px solid", color), collapse = " ")
  ))
}

addOverlayLayer <- function(map, data, lat, lng, color, group, label, weight = 4, fillOpacity = 0.3) {
  map %>% addCircleMarkers(
    data = data,
    lat = lat,
    lng = lng,
    weight = weight,
    fillOpacity = fillOpacity,
    color = color,
    group = group,
    # label = label %>% lapply(htmltools::HTML),
    # labelOptions = labelOptions(
    #   style = getTooltipStyles(color),
    #   textsize = "15px",
    #   direction = "auto"
    popup = label %>% lapply(htmltools::HTML),
    popupOptions = popupOptions(
      className = paste("map-circle-popup", paste0("popup-color-", gsub('#', '', color))),
    ),
    options = pathOptions(pane = "shapes")
  )
}

addBaseLayer <- function(map,
                         legend_colors = c("#EFEFEF", "#F98C09", "#D34743", "#B0325A", "#741A6E", "#4A126B", "#1A0C41", "#00010D"),
                         legend_labels,
                         legend_values,
                         legend_title,
                         group,
                         country,
                         country_fill,
                         country_label,
                         country_colors) {
  map %>%
    addLegend("bottomleft",
      colors = legend_colors,
      labels =  legend_labels,
      values = legend_values,
      title = legend_title,
      className = paste(c("info", "legend", gsub(" ", "-", group)), collapse = " ")
    ) %>%
    addPolygons(
      stroke = FALSE,
      smoothFactor = 1,
      fillOpacity = 0.65,
      fillColor = country_fill,
      label = country_label %>% #Non_Government_policies_total
        lapply(htmltools::HTML),
      options = pathOptions(
        class = paste0("country-shape ", gsub(" ", "_", country)),
        pane = "bases"
      ),
      labelOptions = labelOptions(
        style = getTooltipStyles("#151e2d"),
        textsize = "15px",
        direction = "auto"
      ),
      group = group
    )
}


# create base map
basemap <- baseMap(
  baseGroups =  c(
    # "Fossil Fuel Production",
    "Oil",
    "Gas",
    "Coal"
    # "Oil Production",
    # "Gas Production",
    # "Coal Production"
  ),
  overlayGroups = c(
    "Policies",
    "Cities, States, Regions", "Divestments",
    "Fossil Fuel Non-Proliferation"
  )) %>%

  addBaseLayer(
    legend_labels = c("No data", "1-5 million t", "1-10 million t", "10-50 million t","50-100 million t", "100-500 million t", "1 billion t", "5 billion t"),
    legend_values = ~country_overview_large$co2_oil_annual_2019_cat,
    legend_title = "CO2 Emissions<br/>Oil 2019",
    group = "Oil",
    country = country_overview_large$Country,
    country_fill = ~cv_pal_oil_co2(country_overview_large$co2_oil_annual_2019_cat),
    country_label = sprintf("
      <strong>%s</strong>
      <small>Policies: %g</small><br/>
      <small>Divestments: %g</small><br/>
      <small>CO2 Emissions Oil 2019: %s </small><br/>
      <small>Climate Risk Index: %s</small>",
      #%s</small><br/><small>Total number of policies: %g</small>
      country_overview_large$Country,
      country_overview_large$Government_policies_total,
      country_overview_large$Non_Government_policies_total,
      country_overview_large$co2_oil_annual_2019,
      country_overview_large$cri
    ),
    country_colors = cv_pal_oil_co2
  ) %>%

  addBaseLayer(
    legend_labels = c("No data", "1-5 million t", "1-10 million t", "10-50 million t","50-100 million t", "100-500 million t", "1 billion t", "5 billion t"),
    legend_values = ~country_overview_large$co2_gas_annual_2019_cat,
    legend_title = "CO2 Emissions<br/>Gas 2019",
    group = "Gas",
    country = country_overview_large$Country,
    country_fill = ~cv_pal_gas_co2(country_overview_large$co2_gas_annual_2019_cat),
    country_label = sprintf("
      <strong>%s</strong>
      <small>Policies: %g</small><br/>
      <small>Divestments: %g</small><br/>
      <small>CO2 Emissions Gas 2019: %s </small><br/>
      <small>Climate Risk Index: %s</small>",
      #%s</small><br/><small>Total number of policies: %g</small>
      country_overview_large$Country,
      country_overview_large$Government_policies_total,
      country_overview_large$Non_Government_policies_total,
      country_overview_large$co2_gas_annual_2019,
      country_overview_large$cri
    ),
    country_colors = cv_pal_gas_co2
  ) %>%

  addBaseLayer(
    legend_labels = c("No data", "1-5 million t", "1-10 million t", "10-50 million t","50-100 million t", "100-500 million t", "1 billion t", "> 7 billion t"),
    legend_values = ~country_overview_large$co2_coal_annual_2019_cat,
    legend_title = "CO2 Emissions<br/>Coal 2019",
    group = "Coal",
    country = country_overview_large$Country,
    country_fill = ~cv_pal_coal_co2(country_overview_large$co2_coal_annual_2019_cat),
    country_label = sprintf("
      <strong>%s</strong>
      <small>Policies: %g</small><br/>
      <small>Divestments: %g</small><br/>
      <small>CO2 Emissions Coal 2019: %s </small><br/>
      <small>Climate Risk Index: %s</small>",
      #%s</small><br/><small>Total number of policies: %g</small>
      country_overview_large$Country,
      country_overview_large$Government_policies_total,
      country_overview_large$Non_Government_policies_total,
      country_overview_large$co2_coal_annual_2019,
      country_overview_large$cri
    ),
    country_colors = cv_pal_coal_co2
  ) %>%

  addOverlayLayer(
    data = country_overview_large_map,
    lat = ~latitude,
    lng = ~longitude,
    color = Policies,
    group = "Policies",
    label = sprintf("
      <strong>%s</strong>
      <small>Policies: %g</small>",
      country_overview_large_map$Country,
      country_overview_large_map$Government_policies_total
    )
  ) %>%

  # Add divestments layer
  addOverlayLayer(
    data = country_overview_large_map,
    lat = ~latitude,
    lng = ~longitude,
    color = Divestments,
    group = "Divestments",
    label = sprintf("
      <strong>%s</strong>
      <small>Divestments: %g</small>",
      country_overview_large_map$Country,
      country_overview_large_map$Non_Government_policies_total
    )
  ) %>%

  # Add Cities, States, Regions layer
  addOverlayLayer(
    data = state_city_breakdown_map,
    lat = ~latitude,
    lng = ~longitude,
    color = Cities_regions_states,
    group = "Cities, States, Regions",
    label = sprintf("
      <strong>%s</strong>
      <small>Moratoria, Bans, Limits: %g</small>
      <small>Subsidy Removals: %d</small>
      <small>Divestments: %g</small>
      <small>FF NPT: %g</small>",
      state_city_breakdown_map$State_city_region,
      state_city_breakdown_map$Moratoria_bans_limits_total,
      state_city_breakdown_map$Subsidy_removal_total,
      state_city_breakdown_map$Divestment_total,
      state_city_breakdown_map$ffnpt_total
    )
  ) %>%

  # Add Fossil Fuel Non-Proliferation layer
  addOverlayLayer(
    data = state_city_breakdown_map_ffnpt,
    lat = ~latitude,
    lng = ~longitude,
    color = FFNPT_total,
    group = "Fossil Fuel Non-Proliferation",
    label = sprintf(
      "<strong>%s</strong>
      <small>Fossil Fuel Non-Proliferation: %g</small>
      <small><a target='_target' href='%s'>View More...</a></small>",
      state_city_breakdown_map_ffnpt$State_city_region,
      state_city_breakdown_map_ffnpt$ffnpt_total,
      state_city_breakdown_map_ffnpt$Source
      #"http://google.com"
    ),
    weight = 3,
    fillOpacity = 0.3
  )
