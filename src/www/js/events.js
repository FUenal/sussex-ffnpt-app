let updateLegend = function () {
   var selectedGroup = document.querySelectorAll('input:checked')[0].nextSibling.innerText.substr(1)
    .split(' ').join('-');

   document.querySelectorAll('.legend').forEach(a => a.hidden=true);
   document.querySelectorAll('.legend').forEach(l => {
      if (l.classList.contains(selectedGroup)) l.hidden=false;
   });

   set_default_selected_country(active_country);
};

$(document).ready(function() {
  var header = document.getElementById('sidebar_tabs');
  var introduction = header.querySelector('[data-tab=introduction]');
  var timeDropdown = document.querySelector('.dropdown__time');
  var burgerButton = document.getElementById('burger_button');
  var tabsMenu = document.getElementById('sidebar_tabs');
  var tabsMenuItems = document.querySelectorAll('.item[data-tab]');

  burgerButton.addEventListener('click', function() {
    tabsMenu.classList.toggle('sidebar-menu--visible');
    burgerButton.classList.toggle('mobile-header__button--active');
  })

  for (var item of tabsMenuItems) {
    item.addEventListener('click', function() {
      this.parentElement.classList.remove('sidebar-menu--visible');

      [...this.parentElement.querySelectorAll('[data-tab]')]
        .map(item => item.classList.remove("active"));
      this.classList.add("active");

      [...this.parentElement.parentElement.querySelectorAll(`:scope > .ui.tab[data-tab]`)]
          .map(item => item.classList.remove("active"));

      if (this.parentElement.id == "sidebar_tabs") {
        $([document.documentElement, document.body]).animate({scrollTop: 0}, 1);
      }

      document.querySelector(`.ui.tab[data-tab=${this.dataset.tab}]`)
        .classList.add("active");

      Shiny.setInputValue(`tab_${this.dataset.tab}`, active_country, {priority: "event"})

      if (this.dataset.tab == "country_profiles") {
        if (!!document.querySelectorAll('input:checked').length) {
           updateLegend();
        }
        
        Shiny.setInputValue(`tab_${document.getElementById('details_one_tabs').querySelector(".item.active").dataset.tab}`, active_country, {priority: "event"})
        Shiny.setInputValue(`tab_${document.getElementById('details_two_tabs').querySelector(".item.active").dataset.tab}`, active_country, {priority: "event"})
        Shiny.setInputValue(`tab_${document.getElementById('details_three_tabs').querySelector(".item.active").dataset.tab}`, active_country, {priority: "event"})
      }
    })
  }
});
