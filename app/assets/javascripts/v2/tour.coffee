$(document).on 'page:change', ->
  $(".dropdown-menu").find("a").click (e) ->
    e.preventDefault()
    section = $(this).attr "href"
    $("html, body").animate
      scrollTop: $(section).offset().top

  $('.back-to-top').click (e) ->
    e.preventDefault()
    $('html, body').animate
      scrollTop: 0, 500
