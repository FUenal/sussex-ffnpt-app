### SHINY UI ###
ui <- semanticPage(
    title = "Fossil Fuel Non-Proliferation Tracker",
    theme = NULL,
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/sass.min.css"),
      tags$script(src = "js/scripts.js"),
      tags$script(src = "js/events.js")
    ),
    useShinyjs(),
    tags$main(
      class = "main",
      h1(class = "main__heading visuallyhidden", "Visalize Madagascar Dashboard"),
      img(
        src = "FF-Initiative_white text-01.png",
        alt = "FFNPT",
        style = "
          position: fixed;
          height:30px;
          width: auto;
          z-index: 10000;
          left: 2px;
          top: 15px; 
        "
      ),
      tags$header(
        class = "mobile-header",
        logo,
        button(
          "burger_button",
          "",
          class = "mobile-header__button",
          icon = icon("hamburger")
        )
      ),
      tabset(
        id = "sidebar_tabs",
        active = 'introduction',
        menu_class = "sidebar-menu sidebar visible menu",
        tab_content_class = "sidebar-tab",
        list(
          # list(
          #   menu = a(href = "https://fossilfueltreaty.org", target="_blank", div(
          #     style = "background: white; width: 100%; height: 100%;")),
          #   id = 'app_logo'
          # ),
          list(
            menu = "Intro",
            content = introduction_ui(),
            id = 'introduction'
          ),
          list(
            menu = "Country Profiles",
            content = country_profiles_ui,
            id = 'country_profiles'
          ),
          list(
            menu = "Policy Overview",
            content = policy_overview_ui,
            id = 'policy_overview'
          ),
          list(
            menu = "About",
            content = about_ui,
            id = 'about'
          ),
          list(
            menu = "How to",
            content = how_to_ui,
            id = 'how_to'
          ),
          list(
            menu = "Download",
            content = download_ui,
            id = 'download'
          )
        )
      )
    ),
    div(
      id = "help-modal",
      class = "modal",
      div(
        class = "modal-header",
        tags$p("modal text")
      ),
      div(
        class = "modal-content",
        tags$p("modal text")
      )
    )
  )
