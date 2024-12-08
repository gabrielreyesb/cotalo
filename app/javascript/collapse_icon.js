document.addEventListener("turbolinks:load", function() {
    $('#manualMaterialCollapse').on('show.bs.collapse', function () {
      $('[data-quotes-target="openIcon"]').hide();
      $('[data-quotes-target="closeIcon"]').show();
    });
  
    $('#manualMaterialCollapse').on('hide.bs.collapse', function () {
      $('[data-quotes-target="closeIcon"]').hide();
      $('[data-quotes-target="openIcon"]').show();
    });
  });