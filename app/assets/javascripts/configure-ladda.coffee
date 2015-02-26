$(document).ready ->
  $(".btn.btn-system.ladda-button").each ->
    _this = $(this)
    _this.closest("form").submit (e) ->
      _this.find('.ladda-label').text(_this.data('submit-text') || "Submitting")
      Ladda.create(_this[0]).start()