typedjsAnimation = ->
  typed = new Typed('#typed',
  stringsElement: '#typed-strings'
  typeSpeed: 20
  backSpeed: 20
  backDelay: 3000
  cursorChar: '_'
  shuffle: true
  smartBackspace: false
  loop: true)

counterUp = ->
  $('.program-stats__counter').counterUp
    time: 1000

$(document).on 'turbolinks:load', ->
  if $('#stats-index')
    typedjsAnimation()
    counterUp()