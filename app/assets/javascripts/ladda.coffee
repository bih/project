$(document).ready ->
  $(".btn.btn-system").each ->
    _this = $(this)
    _this.closest("form").submit (e) ->
      e.preventDefault()

      # _this.val(_this.data('text') || "Submitting")
      Ladda(_this[0]).start()