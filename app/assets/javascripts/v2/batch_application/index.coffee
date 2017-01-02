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
    moreLink: '<a class="read-more-link" href="#">Read More</a>'

emailsShouldMatch = ->
  batchApplicationForm = $('#new_batch_application')
  if batchApplicationForm.length
    emailInput = $('#batch_application_email')
    emailConfirmationInput = $('#batch_application_email_confirmation')

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

getCollegeInputSelector = ->
  collegeInput = $('#batch_application_college_id')

  if collegeInput.length == 0
    collegeInput = $('#prospective_applicant_college_id')

  collegeInput

setupSelect2Inputs = ->
  collegeInput = getCollegeInputSelector()

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
  collegeInput = getCollegeInputSelector()

  if collegeInput.length
    collegeInput.select2('destroy')
    collegeInput.val('')

toggleReferenceTextField = ->
  if $('#batch_application_reference').val() == 'Other (Please Specify)'
    referenceTextInput = $('#batch_application_reference_text')
    referenceTextInput.parent().parent().removeClass('hidden-xs-up')
    $('#batch_application_reference').parent().addClass('hidden-xs-up')
    referenceTextInput.focus()

setupTogglingReferenceField = ->
  if $('#batch_application_reference').length
    toggleReferenceTextField()
    $('#batch_application_reference').change toggleReferenceTextField

toggleCollegeTextField = ->
  formName = null

  if $('#batch_application_college_id').val() == 'other'
    formName = 'batch_application'
  else if $('#prospective_applicant_college_id').val() == 'other'
    formName = 'prospective_applicant'

  if formName != null
    collegeTextInput = $("##{formName}_college_text")
    collegeTextInput.prop('disabled', false)
    collegeTextInput.parent().parent().removeClass('hidden-xs-up')
    $("##{formName}_college_id").parent().addClass('hidden-xs-up')
    collegeTextInput.focus()

setupTogglingCollegeField = ->
  if $('#batch_application_college_id').length
    toggleCollegeTextField()
    $('#batch_application_college_id').change toggleCollegeTextField

  if $('#prospective_applicant_college_id').length
    toggleCollegeTextField()
    $('#prospective_applicant_college_id').change toggleCollegeTextField

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

setupOldApplicationCertificateDownloadButtons = ->
  $('.download-old-application-certificate').click (event) ->
    certificateBackground = $('#application-certificate-background').data('background')

    downloadCertificateButton = $(event.target)
    teamMembers = downloadCertificateButton.closest('.application-certificate-data').data('teamMembers')
    codeScore = downloadCertificateButton.closest('.application-certificate-data').data('codeScore')
    videoScore = downloadCertificateButton.closest('.application-certificate-data').data('videoScore')
    result = downloadCertificateButton.closest('.application-certificate-data').data('result')

    doc = buildApplicationCertificate(certificateBackground, teamMembers, codeScore, videoScore, result)
    doc.save('Certificate.pdf')

$(document).on 'page:change', setupTogglingCollegeField
$(document).on 'page:change', setupTogglingReferenceField
$(document).on 'page:change', setupOldApplicationCertificateDownloadButtons
$(document).on 'page:change', emailsShouldMatch
$(document).on 'page:change', scrolltoStartapplicationForm
$(document).on 'page:change', stickyApplyButtonOnApplyPage
$(document).on 'page:change', helpIntercomPopup
$(document).on 'page:change', readmoreFAQ
$(document).on 'page:before-change', destroyWaypoints

$(document).on 'turbolinks:load', ->
  if $('.batch-application__index').length
    setupSelect2Inputs()
    setupStickyStartApplicationForm()

$(document).on 'turbolinks:before-cache', ->
  if $('.admission-process').length
    destroySelect2Inputs()
