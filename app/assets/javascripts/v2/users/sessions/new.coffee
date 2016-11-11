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
    federatedLoginBlock.addClass('hidden-xs-up')
    emailLoginBlock.removeClass('hidden-xs-up')
    federatedLoginLink.removeClass('hidden-xs-up')
    emailLoginLink.addClass('hidden-xs-up')
  else if method == 'federated'
    federatedLoginBlock.removeClass('hidden-xs-up')
    emailLoginBlock.addClass('hidden-xs-up')
    federatedLoginLink.addClass('hidden-xs-up')
    emailLoginLink.removeClass('hidden-xs-up')
  else
    console.error("Unknown method of login requested: #{method}")

$(document).on 'turbolinks:load', ->
  if $('#sign-in-with-email').length
    setupSwitchSignIn()
