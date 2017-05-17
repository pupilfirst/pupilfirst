# Global variables required for the youtube API
window.player = null
window.videoPlayed = false

handleGAEvents = ->
  #  someone visited the SaaS article on apply page
  if $('#saas-article-link').length
    $('#saas-article-link').on('click', (event) ->
      ga('send', 'event', 'Link', 'click', 'SaaS-article'))

  #  someone just signed up and started his dashboard tour
  if $('#dashboard-show-tour').length && $('#dashboard-show-tour').data('tour-flag')
    ga('send', 'event', 'Admission-Milestones', 'Signed-Up')

  # someone played the alpha launch video on apply page
  window.onYouTubeIframeAPIReady = (event) ->
    console.log('onYouTubeIframeAPIReady triggered!')
    window.player = new (YT.Player)('alpha-launch-video__embed', events:
      'onStateChange': onPlayerStateChange)

  window.onPlayerStateChange = (event) ->
    if (event.data == YT.PlayerState.PLAYING) && !window.videoPlayed
      window.videoPlayed = true
      ga('send', 'event', 'Video', 'play', 'Alpha launch')
    if (event.data == YT.PlayerState.ENDED)
      ga('send', 'event', 'Video', 'complete', 'Alpha launch')

  # someone just clicked the 'Pay Now' button on the fee page
  if $('#pay-now-button').length
    $('#pay-now-button').on('click', (event) ->
      ga('send', 'event', 'Admission-Milestones', 'Payment Initiated'))

$(document).on 'page:change', handleGAEvents
