setupGraduationCarousel = ->
   $(".graduation-carousel").slick
     slidesToShow: 3
     arrows: true
     centerMode: true
     adaptiveHeight: true
     responsive: [
       {
         breakpoint: 992,
         settings: {
           centerMode: true
           slidesToShow: 3
         }
       },
       {
         breakpoint: 768,
         settings: {
           centerMode: true
           slidesToShow: 1
         }
       }
     ]
infinite: true

setupStoryCarousel = ->
  $(".story-container").slick
    slidesToShow: 3
    slidesToScroll: 1
    dots: false
    arrows: true
    responsive: [
      {
        breakpoint: 992,
        settings: {
          slidesToShow: 2
        }
      },
      {
        breakpoint: 768,
        settings: {
          slidesToShow: 1
          slidesToScroll: 1
          arrows: false
        }
      }
    ]
    infinite: true

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
$(document).on 'page:change', setupGraduationCarousel
$(document).on 'page:change', scrollmeDownIcon
$(document).on 'page:change', setupStoryCarousel
