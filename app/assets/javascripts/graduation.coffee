$(document).on 'page:change', ->
  $(".company-carousel").owlCarousel
    items:4
    margin:10
    autoPlay:10000
    stopOnHover:true

  $(".testimonial-carousel").owlCarousel
    items:1
    autoPlay:20000
    stopOnHover:true
    itemsDesktop:[1920,1]
    itemsTablet:[768,1]
