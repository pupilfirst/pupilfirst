stopVideosOnModalClose = ->
  $('.video-modal').on 'hide.bs.modal', (event) ->
    modalIframe = $(event.target).find('iframe')
    modalIframe.attr 'src', modalIframe.attr('src')

$(document).on 'page:change', stopVideosOnModalClose

# !!! NEW STUFF !!!
expandFramework = ->
  $('.program-framework__timeline-title').click (e) ->
    $(this).next().slideToggle()
    $(this).toggleClass('active')

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
          return {results: data}
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
    referenceTextInput.parent().parent().removeClass('d-none')
    $('#founders_registration_reference').parent().addClass('d-none')
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
    collegeTextInput.parent().parent().removeClass('d-none')
    $("##{formName}_college_id").parent().addClass('d-none')
    collegeTextInput.focus()

setupTogglingCollegeField = ->
  collegeInput = $('#founders_registration_college_id')

  if collegeInput.length == 0
    collegeInput = $('#prospective_applicants_registration_college_id')

  if collegeInput.length
    toggleCollegeTextField()
    collegeInput.change toggleCollegeTextField

helpIntercomPopup = ->
  $(".help-intercom-link").click (e) ->
    e.preventDefault()
    Intercom('show')

setupPasswordHintButtons = ->
  $('#application-form__password-hint-accept').on('click', replaceEmailWithHint)
  $('#application-form__password-hint-reject').on('click', acceptEmailInputfromUser)

dismissHint = (event) ->
  event.preventDefault()
  $(event.target).closest('.form-text').slideUp()

replaceEmailWithHint = (event) ->
  $('#founders_registration_email').val($('#founders_registration_email').data('replacementHint'))
  dismissHint(event)

acceptEmailInputfromUser = (event) ->
  $('#founders_registration_ignore_email_hint').val('true')
  dismissHint(event)

# Callback function for invisible recaptcha present in the registration form. This callback is called when the recaptcha
# verification is completed successfully - so a flag is set using a data attribute to indicate this.
window.handleFounderJoinButton = ->
  registrationForm = $('#new_founders_registration')
  registrationForm.data('recaptchaComplete', 'true')
  registrationForm.submit()

# Sets up the registration form to prevent submission if recaptcha verfication is incomplete, and trigger it manually.
setupJoinFormHandler = ->
  $('#new_founders_registration').submit (event) ->
    registrationForm = $('#new_founders_registration')

    return if registrationForm.data('test')

    unless registrationForm.data('recaptchaComplete')
      event.preventDefault()
      grecaptcha.reset()
      grecaptcha.execute()

$(document).on 'page:change', setupTogglingCollegeField
$(document).on 'page:change', setupTogglingReferenceField
$(document).on 'page:change', helpIntercomPopup
$(document).on 'page:change', expandFramework

$(document).on 'turbolinks:load', ->
  if $('#admissions__join').length
    setupSelect2Inputs()
    setupPasswordHintButtons()
    setupJoinFormHandler()

$(document).on 'turbolinks:before-cache', ->
  if $('.admission-process').length
    destroySelect2Inputs()
