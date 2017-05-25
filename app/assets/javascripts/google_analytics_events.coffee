# Global variables required for the YouTube API.
window.player = null
window.videoPlayed = false

handleGAEvents = ->
  # Alpha launch video on apply page.
  window.onYouTubeIframeAPIReady = (event) ->
    window.player = new (YT.Player)(
      'alpha-launch-video__embed',
      events: { 'onStateChange': onPlayerStateChange }
    )

  window.onPlayerStateChange = (event) ->
    if (event.data == YT.PlayerState.PLAYING) && !window.alphaLaunchVideoPlayed
      window.alphaLaunchVideoPlayed = true

      dataLayer.push(
        'event': 'video'
        'videoState': 'play',
        'videoName': 'Alpha launch'
      )

    if (event.data == YT.PlayerState.ENDED)
      dataLayer.push(
        'event': 'video'
        'videoState': 'complete',
        'videoName': 'Alpha launch'
      )

  # someone just clicked the 'Pay Now' button on the fee page
  if $('#pay-now-button').length
    $('#pay-now-button').on('click', (event) ->
      ga('send', 'event', 'Admission-Milestones', 'Payment Initiated')
      # keeping it here for the time being. See: https://trello.com/c/FhjsWYzO
      # Initiate the Facebook standard InitiateCheckout Event
      fbq('track', 'InitiateCheckout')
      # Also initiate a custom event
      fbq('trackCustom', 'Payment Initiated')
    )


$(document).on 'page:change', handleGAEvents
