$(document).ready ->
  $(".delete-confirmation").click (e) ->
    if confirm("Are you sure you want to do this? It cannot be reversed.") == false
      e.preventDefault()
      return false