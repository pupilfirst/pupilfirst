setupCompanyCarousel = ->
  $(".company-carousel").slick
    slidesToShow: 4
    slidesToScroll: 2
    dots: true
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
          arrows: false
        }
      }
    ]
    infinite: true

setupTestimonialCarousel = ->
  testimonialCarousel = $(".testimonial-carousel")

  testimonialCarousel.slick
    dots: true
    arrows: true
    infinite: true

  testimonialCarousel.on 'beforeChange', (event, slick, currentSlide, nextSlide) ->
    previousSlide = $(".testimonial-slide-item[data-slick-index='#{currentSlide}']")
    videoContent = previousSlide.find('iframe')[0].contentWindow
    console.log videoContent
    videoContent.postMessage('{"event":"command","func":"stopVideo","args":""}', '*');

animateHeroHeadline = ->
  if $('.talent-hero').length > 0
    $.codyhouseTextAnimation()

showTalentFormOnError = ->
  talentFormModal = $('.invest-hire-modal')

  if talentFormModal.data('showOnLoad')
    talentFormModal.modal('show')

clearAllFormInterests = ->
  interestChoices = ['joining_svco_as_faculty', 'accelerating_startups', 'investing_in_startups', 'hiring_founders',
    'acquihiring_teams']

  $.each interestChoices, (index, selection) ->
    $("#talent_form_query_type_#{selection}").prop('checked', false)

handleActionButtonClicks = ->
  $('.talent-action-btn').click (event) ->
    selection = $(event.target).data('selection')
    clearAllFormInterests()
    $("#talent_form_query_type_#{selection}").prop('checked', true)
    $('.invest-hire-modal').modal('show')

pauseVideosOnTalentTabSwitch = ->
  if $('.talent-tab-content').length > 0
    $('a[data-toggle="tab"]').on 'hide.bs.tab', (event) ->
      oldTabId = $(event.target).attr('href')
      videoContent = $(oldTabId).find('iframe')[0].contentWindow
      videoContent.postMessage('{"event":"command","func":"stopVideo","args":""}', '*');

$(document).on 'page:change', animateHeroHeadline
$(document).on 'page:change', showTalentFormOnError
$(document).on 'page:change', handleActionButtonClicks
$(document).on 'page:change', pauseVideosOnTalentTabSwitch
$(document).on 'page:change', setupCompanyCarousel
$(document).on 'page:change', setupTestimonialCarousel
