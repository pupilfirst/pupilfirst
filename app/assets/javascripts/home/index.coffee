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

destroySlickSlider = ->
  $(".silicon-valley-itinerary__slider").slick('unslick');

stopVideosOnModalClose = ->
  $('.video-modal').on 'hide.bs.modal', (event) ->
    modalIframe = $(event.target).find('iframe')
    modalIframe.attr 'src', modalIframe.attr('src')

$(document).on 'turbolinks:load', ->
  if $('#home__index')
    setupSiliconValleyCarousel()

$(document).on 'turbolinks:before-cache', ->
  if $('#home__index').length > 0
    destroySlickSlider()
