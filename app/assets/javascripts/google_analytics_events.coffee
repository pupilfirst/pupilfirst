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

$(document).on 'page:change', handleGAEvents
