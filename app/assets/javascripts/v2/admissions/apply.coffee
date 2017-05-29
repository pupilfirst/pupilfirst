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
  $('.video-modal').on 'hide.bs.modal', (event) ->
    modalIframe = $(event.target).find('iframe')
    modalIframe.attr 'src', modalIframe.attr('src')

$(document).on 'page:change', avoidwidowsTypography
$(document).on 'page:change', stopVideosOnModalClose
$(document).on 'page:change', setupProgramCarousel

# !!! NEW STUFF !!!

readmoreFAQ = ->
  $('.read-more').readmore
    speed: 200
    collapsedHeight: 200
    lessLink: '<a class="read-less-link" href="#">Read Less</a>'
    moreLink: '<a id="gtm__read-more-link" class="read-more-link" href="#">Read More</a>'

emailsShouldMatch = ->
  founderRegistrationForm = $('#new_founders_registration')

  if founderRegistrationForm.length
    emailInput = $('#founders_registration_email')
    emailConfirmationInput = $('#founders_registration_email_confirmation')

    validateEmailMatch = ->
      email = emailInput.val()

      if email != emailConfirmationInput.val()
        unless emailConfirmationInput.parent().find('span').length
          emailConfirmationInput.after('<span class="help-block">email addresses do not match</span>')

        emailConfirmationInput.parent().addClass('has-error')
      else
        emailConfirmationInput.parent().find('span').remove()
        emailConfirmationInput.parent().removeClass('has-error')

    emailConfirmationInput.blur ->
      validateEmailMatch()

    emailInput.blur ->
      validateEmailMatch() if emailConfirmationInput.val().length

setupSelect2Inputs = ->
  collegeInput = $('#founders_registration_college_id')

  if collegeInput.length == 0
    collegeInput = $('#prospective_applicants_registration_college_id')

  if collegeInput.length
    collegeSearchUrl = collegeInput.data('searchUrl')

    collegeInput.select2
      minimumInputLength: 3,
      placeholder: 'Please pick your college',
      ajax:
        url: collegeSearchUrl,
        dataType: 'json',
        delay: 500,
        data: (params) ->
          return {
            q: params.term
          }
        ,
        processResults: (data, params) ->
          return { results: data }
        cache: true

destroySelect2Inputs = ->
  collegeInput = $('#founders_registration_college_id')

  if collegeInput.length == 0
    collegeInput = $('#prospective_applicants_registration_college_id')

  if collegeInput.length
    collegeInput.select2('destroy')
    collegeInput.val('')

toggleReferenceTextField = ->
  if $('#founders_registration_reference').val() == 'Other (Please Specify)'
    referenceTextInput = $('#founders_registration_reference_text')
    referenceTextInput.parent().parent().removeClass('hidden-xs-up')
    $('#founders_registration_reference').parent().addClass('hidden-xs-up')
    referenceTextInput.focus()

setupTogglingReferenceField = ->
  if $('#founders_registration_reference').length
    toggleReferenceTextField()
    $('#founders_registration_reference').change toggleReferenceTextField

toggleCollegeTextField = ->
  formName = null

  if $('#founders_registration_college_id').val() == 'other'
    formName = 'founders_registration'
  else if $('#prospective_applicants_registration_college_id').val() == 'other'
    formName = 'prospective_applicants_registration'

  if formName != null
    collegeTextInput = $("##{formName}_college_text")
    collegeTextInput.prop('disabled', false)
    collegeTextInput.parent().parent().removeClass('hidden-xs-up')
    $("##{formName}_college_id").parent().addClass('hidden-xs-up')
    collegeTextInput.focus()

setupTogglingCollegeField = ->
  collegeInput = $('#founders_registration_college_id')

  if collegeInput.length == 0
    collegeInput = $('#prospective_applicants_registration_college_id')

  if collegeInput.length
    toggleCollegeTextField()
    collegeInput.change toggleCollegeTextField

setupStickyStartApplicationForm = ->
  stickApplicationForm()

  $('#fee-accordion').on 'show.bs.collapse', ->
    stickApplicationForm(scope = StickScope.Document)

  $('#fee-accordion').on 'shown.bs.collapse', ->
    stickApplicationForm()

  $('#fee-accordion').on 'hidden.bs.collapse', ->
    stickApplicationForm()

stickApplicationForm = (scope = StickScope.Parent) ->
  $('#start-application-process').stickit('destroy')
  $('#start-application-process').stickit
    top: 0,
    screenMinWidth: 992,
    scope: scope

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
          $('#intercom-container').addClass('hidden-xs-down')
      exited: (direction) ->
        if direction == 'up'
          $('#sticky-start-application').removeClass('hidden-xs-up')
          $('#intercom-container').removeClass('hidden-xs-down')

destroyWaypoints = ->
  if $('.application-process').length
    Waypoint.destroyAll()

helpIntercomPopup = ->
  $(".help-intercom-link").click (e) ->
    e.preventDefault()
    Intercom('show')

$(document).on 'page:change', setupTogglingCollegeField
$(document).on 'page:change', setupTogglingReferenceField
$(document).on 'page:change', scrolltoStartapplicationForm
$(document).on 'page:change', stickyApplyButtonOnApplyPage
$(document).on 'page:change', helpIntercomPopup
$(document).on 'page:change', readmoreFAQ
$(document).on 'page:before-change', destroyWaypoints

$(document).on 'turbolinks:load', ->
  if $('#admissions__apply').length
    setupSelect2Inputs()
    setupStickyStartApplicationForm()
    emailsShouldMatch()

$(document).on 'turbolinks:before-cache', ->
  if $('.admission-process').length
    destroySelect2Inputs()
