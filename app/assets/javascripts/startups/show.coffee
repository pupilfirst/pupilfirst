#= require shorten/jquery.shorten

shortenText = ->
  $('.about-startup').shorten(
    showChars: 200
  )

$(shortenText)

$(->
  $('a#verified-icon').tooltip()
)

$(->
  $(".tl_link_button").click((e) ->
    if ($(this).find(".ink").length == 0)
      $(this).prepend("<span class='ink'></span>")

    ink = $(this).find(".ink")
    ink.removeClass("animate")

    if (!ink.height() && !ink.width())
      d = Math.max($(this).outerWidth(), $(this).outerHeight())
      ink.css({height: d, width: d})

    x = e.pageX - $(this).offset().left - ink.width() / 2
    y = e.pageY - $(this).offset().top - ink.height() / 2

    ink.css({top: y + 'px', left: x + 'px'}).addClass("animate")
  )
)

$(->
  $('#read-from-beginning').click(->
    $('html, body').animate({scrollTop: $(document).height()}, 'slow')
    return false
  )

  if ($(window).width() < 767)
    $("#verified").removeClass("tooltip-right")
    $("#verified").removeAttr("data-tooltip")

  $(window).resize(->
    if ($(window).width() < 767)
      $("#verified").removeClass("tooltip-right")
      $("#verified").removeAttr("data-tooltip")
  )
)

$(->
  $("#new_timeline_event").on("ajax:success", (e, data, status, xhr) ->
    console.log 'form handler success'
    $("#new_timeline_event").append xhr.responseText
  ).on "ajax:error", (e, xhr, status, error) ->
    console.log 'form handler error'
    $("#new_timeline_event").append "<p>ERROR</p>"
)
