setupSwitchSignIn = ->
  $('.switch-to-federated').click ->
    switchSignIn('federated')
  $('.switch-to-email').click ->
    switchSignIn('email')

switchSignIn = (method) ->
  federatedLoginBlock = $('#sign-in-with-federated')
  emailLoginBlock = $('#sign-in-with-email')
  federatedLoginLink = $('a.switch-to-federated')
  emailLoginLink = $('a.switch-to-email')

  if method == 'email'
    federatedLoginBlock.addClass('d-none')
    emailLoginBlock.removeClass('d-none')
    federatedLoginLink.removeClass('d-none')
    emailLoginLink.addClass('d-none')
  else if method == 'federated'
    federatedLoginBlock.removeClass('d-none')
    emailLoginBlock.addClass('d-none')
    federatedLoginLink.addClass('d-none')
    emailLoginLink.removeClass('d-none')
  else
    console.error("Unknown method of login requested: #{method}")

$(document).on 'turbolinks:load', ->
  if $('#sign-in-with-email').length
    setupSwitchSignIn()
