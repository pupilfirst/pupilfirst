animateHeaderText = ->
  typed = new Typed(
    '#stats-hero__typed',
    stringsElement: '#stats-hero__typed-strings'
    typeSpeed: 20
    backSpeed: 20
    backDelay: 3000
    cursorChar: '_'
    smartBackspace: false
    loop: true
  )

animateNumbers = ->
  $('.program-stats__counter').counterUp(time: 1000)

$(document).on 'turbolinks:load', ->
  if $('#product-metrics__index')
    animateHeaderText()
    animateNumbers()
