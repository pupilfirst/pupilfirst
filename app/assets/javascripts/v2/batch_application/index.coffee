setupProgramCarousel = ->
  $('.program-slides').slick
    infinite: true
    adaptiveHeight: true
    autoplay: true
    autoplaySpeed: 10000

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
    collapsedHeight: 200
    lessLink: '<a class="read-less-link" href="#">Read Less</a>'
    moreLink: '<a class="read-more-link" href="#">Read More</a>'

$(document).on 'page:change', avoidwidowsTypography
$(document).on 'page:change', stopVideosOnModalClose
$(document).on 'page:change', readmoreFAQ
$(document).on 'page:change', setupProgramCarousel

# !!! NEW STUFF !!!

emailsShouldMatch = ->
  batchApplicationForm = $('#new_batch_application')
  if batchApplicationForm.length
    emailInput = $('#batch_application_team_lead_attributes_email')
    emailConfirmationInput = $('#batch_application_team_lead_attributes_email_confirmation')

    validateEmailMatch = ->
      email = emailInput.val()

      if email != emailConfirmationInput.val()
        unless emailConfirmationInput.parent().find('span').length
          emailConfirmationInput.after('<span class="help-block">does not match</span>')

        emailConfirmationInput.parent().addClass('has-error')
      else
        emailConfirmationInput.parent().find('span').remove()
        emailConfirmationInput.parent().removeClass('has-error')

    emailConfirmationInput.blur ->
      validateEmailMatch()

    emailInput.blur ->
      validateEmailMatch() if emailConfirmationInput.val().length

setupSelect2Inputs = ->
  $('#batch_application_university_id').select2
    matcher: (term, text, opt) ->
      text.toUpperCase().indexOf(term.toUpperCase()) >= 0 || opt.html().toUpperCase().indexOf('OTHER') >= 0

toggleReferenceTextField = ->
  if $('#batch_application_team_lead_attributes_reference').val() == 'Other (Please Specify)'
    referenceTextInput = $('#batch_application_team_lead_attributes_reference_text')
    # debugger
    referenceTextInput.parent().parent().removeClass('hidden-xs-up')
    $('#batch_application_team_lead_attributes_reference').parent().addClass('hidden-xs-up')
    referenceTextInput.focus()

$(document).on 'page:change', ->
  if $('#batch_application_team_lead_attributes_reference').length
    toggleReferenceTextField()
    $('#batch_application_team_lead_attributes_reference').change toggleReferenceTextField

stickStartapplicationForm = ->
  $('#start-application-process').stickit
    top: 0,
    screenMinWidth: 1024

scrolltoStartapplicationForm = ->
  $('#sticky-start-application').click (e) ->
    e.preventDefault()
    $('html, body').animate
      scrollTop: $($.attr(this, 'href')).offset().top, 500

stickyApplyButtonOnApplyPage = ->
  if $('.application-process').length

    visibilityToggle = new Waypoint.Inview
      element: $('#start-application-process')[0]
      enter: (direction) ->
        if direction == 'down'
          $('#sticky-start-application').addClass('hidden-xs-up')
      exited: (direction) ->
        if direction == 'up'
          $('#sticky-start-application').removeClass('hidden-xs-up')


$(document).on 'page:change', setupSelect2Inputs
$(document).on 'page:change', emailsShouldMatch
$(document).on 'page:change', stickStartapplicationForm
$(document).on 'page:change', scrolltoStartapplicationForm
$(document).on 'page:change', stickyApplyButtonOnApplyPage
