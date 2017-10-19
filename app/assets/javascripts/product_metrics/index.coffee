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

$(document).on 'turbolinks:load', ->
  if $('#stats-index')
    typedjsAnimation()