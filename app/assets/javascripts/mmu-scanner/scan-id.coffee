$(document).ready ->

  $.fn.mmuFormScanner = ->
    _this = $(this)

    makeNewScan = ->
      valid = false
      val = _this.find('.mmu-id-scanner').val()

      if val.substr(0, 4) is ";300"
        val = val.substr(4, val.length)
        val = val.substr(0, val.length - 2)

      valid = true if val.length is 8

      if valid
        _this.find('.mmu-id-scanner').removeClass('scanner-wrong').addClass('scanner-right')
      else
        _this.find('.mmu-id-scanner').removeClass('scanner-right').addClass('scanner-wrong')

    _this.find('.mmu-id-scanner').bind('keyup keydown', -> makeNewScan())
    _this.bind('submit', (e) ->
        if _this.find('.mmu-id-scanner.scanner-wrong').length > 0
          e.preventDefault()
      )

  $(".mmu-id-scanner-form").mmuFormScanner()