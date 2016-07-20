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

avoidwidowsTypography = ->
  $('h5').each ->
    wordArray = $(this).text().split(' ')
    if wordArray.length > 1
      wordArray[wordArray.length - 2] += '&nbsp;' + wordArray[wordArray.length - 1]
      wordArray.pop()
      $(this).html wordArray.join(' ')

stopVideosOnModalClose = ->
  $('.graduates-video').on 'hide.bs.modal', (event) ->
    modalIframe = $(event.target).find('iframe')
    modalIframe.attr 'src', modalIframe.attr('src')

readmoreFAQ = ->
  $('.read-more').readmore
    speed: 200
    collapsedHeight: 700
    lessLink: '<a class="read-less-link" href="#">Read Less</a>'
    moreLink: '<a class="read-more-link" href="#">Read More</a>'

stickyApplyButton = ->
  if $('.apply-illustration').length
    stickyToggle = new Waypoint
      element: $('.graduated-slide')[0],
      handler: (direction) ->
        applicationButton = $('#apply-sticky-application-button')
        if direction == 'down'
          applicationButton.removeClass('hidden-xs-up')
        else
          applicationButton.addClass('hidden-xs-up')

    bottomStickyToggle = new Waypoint.Inview
      element: $('.ready-to-apply')[0]
      enter: (direction) ->
        if direction == 'down'
          $('#apply-sticky-application-button').addClass('hidden-xs-up')
      exited: (direction) ->
        if direction == 'up'
          $('#apply-sticky-application-button').removeClass('hidden-xs-up')

removeWaypoints = ->
  if $('.tour-banner').length
    Waypoint.destroyAll()

$(document).on 'page:change', setupGraduationCarousel
$(document).on 'page:change', avoidwidowsTypography
$(document).on 'page:change', stopVideosOnModalClose
$(document).on 'page:change', readmoreFAQ
$(document).on 'page:change', stickyApplyButton
$(document).on 'page:before-change', removeWaypoints
