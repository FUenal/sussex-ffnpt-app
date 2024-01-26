$(document).ready(function() {
  $(document).on("click", function(event) {

    if (event.target.className == "infobutton") {
      $.getJSON("js/help.json", function(json) {
        const help = json;

        console.log(help)

        $(".modal").addClass("active-modal");
        $('#help-modal .modal-header').html(help[event.target.id].title);
        $('#help-modal .modal-content').html(help[event.target.id].content);
        return;
      });
    }
    const modal = document.getElementById("help-modal")
    if (event.target == modal) {
      $(".modal").removeClass("active-modal");
      return;
    }
  });
});


let active_country = 'United_Kingdom';
$(document).ready(function() {
  set_default_selected_country = function() {
    [...document.querySelectorAll(`.country-shape`)]
      .map((node) => node.classList.remove("selected"));

    [...document.querySelectorAll(`.country-shape.${active_country.split(' ').join('_')}`)]
      .map((node) => node.classList.add("selected"));
  }

  const delta = 6;
  let startX;
  let startY;

  $(document).on('mousedown', function (event) {
    startX = event.pageX;
    startY = event.pageY;
  });

  $(document).on('mouseup', function (event) {
    const diffX = Math.abs(event.pageX - startX);
    const diffY = Math.abs(event.pageY - startY);

    if (diffX < delta && diffY < delta) {
      if (event.target.classList.contains("country-shape")) {
        [...event.target.parentElement.querySelectorAll("path.country-shape")]
          .map(node => node.classList.remove("selected"));
        event.target.classList.add("selected");

        $([document.documentElement, document.body]).animate({
          scrollTop: $("#country_title").offset().top - 50
        }, 1);

        active_country = [...event.target.classList].
          filter(x => !['country-shape', 'selected', 'leaflet-interactive']
            .includes(x))[0];

        Shiny.setInputValue("Country", active_country);
      }
    }
  });
});
