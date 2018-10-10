# Callback function for invisible recaptcha present in the registration form. This callback is called when the recaptcha
# verification is completed successfully - so a flag is set using a data attribute to indicate this.
window.handleSignInWithEmailButton = ->
  signInForm = $('#new_user_sign_in')
  signInForm.data('recaptchaComplete', 'true')
  signInForm.submit()

# Sets up the sign in form to prevent submission if recaptcha verfication is incomplete, and trigger it manually.
setupSignInFormWithEmailHandler = ->
  signInForm = $('#new_user_sign_in')

  signInForm.submit (event) ->
    return if signInForm.data('test')

    unless signInForm.data('recaptchaComplete')
      event.preventDefault()
      grecaptcha.reset()
      grecaptcha.execute()

$(document).on 'turbolinks:load', ->
  if $('#new_user_sign_in').length
    setupSignInFormWithEmailHandler()
