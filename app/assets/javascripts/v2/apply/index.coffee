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

$(document).on 'page:change', setupGraduationCarousel
