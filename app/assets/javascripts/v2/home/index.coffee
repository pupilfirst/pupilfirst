setupSiliconValleyCarousel = ->
  $(".silicon-valley-itinerary__slider").slick
    dots: true
    arrows: true
    autoplay: true
    autoplaySpeed: 10000
    infinite: true
    fade: true
    responsive: [
      {
        breakpoint: 1200,
        settings: {
          arrows: false
          fade: false
        }
      }
    ]

stopVideosOnModalClose = ->
  $('.video-modal').on 'hide.bs.modal', (event) ->
    modalIframe = $(event.target).find('iframe')
    modalIframe.attr 'src', modalIframe.attr('src')

showInstagramImageOverlays = ->
  $('.instagram-overlay').hover ->
    $(this).addClass('overlay-enabled')
  , ->
    $(this).removeClass('overlay-enabled')

scrollmeDownIcon = ->
  $('.icon-scroll').click (e) ->
    e.preventDefault()
    $('html, body').animate
      scrollTop: $($.attr(this, 'href')).offset().top, 500

$(document).on 'page:change', showInstagramImageOverlays
$(document).on 'page:change', scrollmeDownIcon
$(document).on 'page:change', setupSiliconValleyCarousel
