# Icon should be a valid name
# available in https://semantic-ui.com/elements/icon.html
intro_card <- function(title, content, icon = "globe") {
  div(
    class = "box",
    div(
      class = "box__upper",
      h2(class = "box__heading", title),
      icon(icon) %>% tagAppendAttributes(
        style = "color: #f58221; font-size: 70px; line-height: 70px;"
      )
    ),
    content
  )
}

introduction_ui <- function() {
  grid(
    grid_template = grid_template(default = list(
      areas = rbind(
        c("heading", "graphic", "graphic"),
        c("text", "graphic", "graphic"),
        c("profiles", "overview", "about"),
        c("heading1", "heading1", "heading1"),
        c("graphic1", "graphic2", "graphic3"),
        c("heading2", "heading2", "heading2"),
        c("text1", "text1", "text1"),
        c("MBL", "SR", "Divestments"),
        c("notes", "notes", "sources")
      ),
      cols_width = c("1fr", "1fr", "1fr")
    )),
    container_style = "gap: 30px; height: 100%; max-width: 1600px;",
    area_styles = list(
      heading = "align-self: end;",
      text = "",
      graphic = "margin: 50px;",
      overview = "",
      simulation = "",
      analysis = "",
      notes = "
        display: flex;
        flex-direction: column;
        padding-top: 50px;
      ",
      sources = "
        display: flex;
        flex-direction: column;
        padding-top: 50px;
      "
    ),
    heading = h1(class = "intro__heading",
      "The Fossil Fuel Non-Proliferation Tracker"
    ),

    text = p(
      class = "intro__text",
      HTML(
      "
      The Fossil Fuel Policy Tracker is an open source tool to help all hands to monitor fossil fuel related 
      policies in all countries globally, to identify best practice, and identify which countries are leaders 
      or laggards. Only by showing which countries are being progressive, and which are backsliding, we will be 
      able to to manage a just, fast, and fair transition away to a clean energy future. <br/><br/>
      This Tracker is an ongoing project and we are constantly adapting and developing 
      our methodology to include as many supply-side policies, from as many contexts, 
      as possible. Please get in touch with suggestions: info@fossilfueltracker.org <br/><br/>
      
      "
      )
    ),

    #graphic = img(class = "intro__graphic", src = "FF-Initiative_clear background-01.png"), 
    graphic = p(
      class = "intro__sources",
    HTML('<iframe width="580" height="315" src="https://www.youtube.com/embed/NX1b_aH6zAg" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; picture-in-picture" allowfullscreen></iframe><br/><br/>
    <b>The Tracker is best viewed on Desktop. <br/>
    The Tracker disconnects after a certain time of inactivity to save resources. <br/>
     Please refresh the page in case of disconnection.</b>')),
      
    #graphic = tags$video(class = "intro__graphic", type = "video/mp4", src = "Policy Tracker Tutorial HD V2.mp4", width="400px", height="200px", controls = "controls"),
    
    profiles = intro_card(
      "Just Transition",
      p(
        class = "box__text",
        span(
          class = "box__text--color", "The Tracker provides data to ensure a just transition,"
        ),
        " a transition in which countries who benefitted most 
        from the burning of fossil fuels help those who contributed the least - but - carry the biggest burden 
        of the climate crisis today. Data on historical fossil fuel production and associated CO2 emissions 
        allows us to determine which countries are mainly responsible for current CO2 levels and thus, ensure 
        a more just transition."
      )
    ),
    overview = intro_card(
      "Fair Transition",
      p(
        class = "box__text",
        span(
          class = "box__text--color", "The Tracker provides data for a fair transition, "
        ),
        "a transition in which countries are not only measured by their 
        policy pledges to reduce fossil fuel extraction and production but also monitored to to go through with 
        their pledges. Tracking policy developments allows us to monitor which countries are on track in reducing 
        their dependency on fossil fuels and which countries are lagging behind. Our Policy tracker tracks supply side
        restriction policies and maps the current state of fossil fuel policy developments to ensure a fair transition."
      )
    ),
    about = intro_card(
      "Fast Transition",
      p(
        class = "box__text",
        span(
          class = "box__text--color", "The Tracker provides contextual data for a fast transition, "
        ),
        "a transition in which all hands see what others are doing.
        Only through up-to-date information can we inform public policy and raise awareness in the public and private sectors. 
        An informed and aware public is critical to to mobilise political and social will which is necessary to fast-track the 
        transition process."
      )
    ),
    
    heading1 = h1(class = "intro__heading",
                  "Our Collaborators"
    ),
    
    graphic1 = img(class = "intro__graphic", src = "Uni of Sussex.png"),
    graphic2 = img(class = "intro__graphic", src = "FF-Initiative_clear background-01.png"), 
    graphic3 = img(class = "intro__graphic", src = "Empty.png"),
    
    heading2 = h1(class = "intro__heading",
                  "Supply Side Policies"
    ),
    text1 = p(
      class = "intro__text",
      HTML(
        "The number and types of supply-side policies in the Tracker are by no means extensive, as there are other policies and initiatives that would constitute as supply-side,
        including taxes on the importation of fossil fuels and blockades. However, to ensure that we begin this project by building the most robust and representative basis for
        tracking supply-side policies, and capture the variety of actors and contextual dynamics present, we have decided to focus on three broad categories of supply-side 
        policies: (1) moratoria, bans, and limitations; (2) subsidy reductions (subsidy removals); and (3) divestments. For more detailed information about our Methodology please
        refer to the 'About' Tab in the menu above.
      "
      )
    ),
    MBL = intro_card(
      "Moratoria, bans, & limitations",
      p(
        class = "box__text",
        span(
          class = "box__text--color", "Moratoria, Bans & Limits:"
        ),
        " These policies include any policy at a national, regional or local level that actively seeks to legally prohibit, ban or limit 
        the extraction and production of oil, gas and coal. Examples include the fracking ban in the Republic of Ireland introduced in 2017 (1)
        or the government of New Zealand refusing to grant new permit licenses for oil exploration (2). 
        This category of supply-side policies includes both the introduction of legislation prohibiting the extraction and production of fossil fuels 
        and the omission of granting new permits and licenses for exploration and extraction. Our methodological approach to capturing these dynamics is evolving."
      )
    ),
    SR = intro_card(
      "Subsidy reductions",
      p(
        class = "box__text",
        span(
          class = "box__text--color", "Subsidy Reductions: "
        ),
        "These policies include legislation and political pledges that seek to remove or phase-out government subsidies for fossil fuels. Unfortunately, there is no agreed 
        international definition for subsidy removals due to the disparities in the methods used to calculate them and the specific context of the country the policies cover. 
        The policies can cover all specific fossil fuels, such as oil and gas, as well as specific types of fuels, like liquified gas that is often used for heating and cooking. 
        At the moment, the tracker gathers both consumer subsidies (for example, a tax reduction on fuel for vehicles) and producer subsidies (for example, a tax break given to 
        oil companies) to provide the most comprehensive overview of this area of climate policy. "
      )
    ),
    Divestments = intro_card(
      "Divestments",
      p(
        class = "box__text",
        span(
          class = "box__text--color", "Divestments: "
        ),
        "The policies and pledges include all initiatives that attempt to exert social, political, and economic pressure on the fossil fuel industry through the institutional 
        and organisational divestment of assets including stocks, bonds, pensions and other financial instruments from companies involved in the extraction, production and sale 
        of fossil fuels. Our data gathers divestment policies from all organisations and institutions in society, no matter how big or small, and includes everything from 
        pledges made by City Councils to those made by local Faith-Based organisations."
      )
    ),
    notes = p(
      class = "intro__notes",
      HTML("
        <a href = 'https://www.irishtimes.com/news/politics/oireachtas/ireland-joins-france-germany-and-bulgaria-in-banning-fracking-1.3137095' target='_blank'> <sup>1</sup> Fracking ban in the Republic of Ireland introduced in 2017 </a><br/>
        <a href = 'https://www.theguardian.com/world/2018/apr/12/new-zealand-bans-all-new-offshore-oil-exploration-as-part-of-carbon-neutral-future' target='_blank'> <sup>2</sup> New Zealand refusing to grant new permit licenses for oil exploration </a><br/><br/>
        The Fossil Fuel Non-Proliferation Tracker is the first of a broader effort to help everyone track and monitor the implementation of just transition plans and 
        fossil fuel phase-out policies on the ground. The Tracker has been developed in partnership with the Fossil Fuel Non-Proliferation Treaty Initiative and the University of Sussex.
        The <a href = 'https://fossilfueltreaty.org/' target='_blank'> Fossil Fuel Non-Proliferation Treaty Initiative</a> 
        is a coalition of civil society organisations, research institutions, grassroot activists and other partners around the world, working to
        influence policy making and investment decisions from local to global level, and lay the foundation for a coordinated, rapid and equitable global phase out of fossil fuels.
      ")
    ),
   
    sources = p(
      class = "intro__sources",
      HTML("
     <b>Programming, AI & Design</b>:<br/>
          Dr. Fatih Uenal - <a href = 'https://dataist.netlify.app/' target='_blank'> The Dataist </a><br/><br/>
     <b>Data, Methodology & Research</b>:<br/>
          Frederick Daley - <a href = 'https://uk.linkedin.com/in/freddie-daley-422908103' target='_blank'> University of Sussex </a>
      ")
    )
  )
}
