# Holder for shared settings.
shared = {}

initializer = ->
  shared.callStarted = false
  loadChatData()
  easyrtc.setSocketUrl shared.chatData.data('easyrtc-socket-url')
  easyrtc.setRoomOccupantListener loggedInListener
  console.log "Entered room as: #{shared.userName}"
  easyrtc.setUsername shared.userName
  easyrtc.dontAddCloseButtons()
  # Remove default close buttons on videos
  easyrtc.easyApp shared.appName, 'self', [ 'caller' ], appSuccessCB
  # initialize easyrtc app
  easyrtc.joinRoom shared.roomName
  easyrtc.setPeerListener hangupOnMsg, 'manualHangup'
  # listener for hangup message from guest
  easyrtc.setOnCall onCallCB
  easyrtc.setOnHangup hangUpCB

# function to load chat data
loadChatData = ->
  shared.chatData = $('#chat-data')
  shared.appName = "SVMentoringEasyRTCApp"
  shared.roomName = "chatRoom#{shared.chatData.data('meeting-id')}"
  shared.userName = shared.chatData.data('current-user-name')
  shared.reminderSent = shared.chatData.data('reminder-sent')
  shared.meetingId = shared.chatData.data('meeting-id')

# function to respond to manual hangup by peer
hangupOnMsg = (easyrtcid, msgType, msgData, targeting) ->
  console.log 'Manual hangup msg received'
  easyrtc.hangupAll()
  $('#end-call').submit()

# function to return peer id when used with filter
notMyself = (myId) ->
  (element) ->
    element isnt myId

loggedInListener = (roomName, otherPeers) ->
  console.log "easyrtcid of Occupants: #{easyrtc.getRoomOccupantsAsArray(roomName)}"

  if easyrtc.getRoomOccupantsAsArray(roomName).length is 1
    singleOccupancyView otherPeers
  else
    multipleOccupancyView otherPeers

singleOccupancyView = (otherPeers) ->
  console.log 'Single occupancy in room'
  resetView()
  $('.awaiting-guest').removeClass 'hidden'
  $('#leave-room-button').removeClass 'hidden'
  if not shared.callStarted and not shared.reminderSent
    $('#send-reminder-button').removeClass 'hidden'

multipleOccupancyView = (otherPeers) ->
  for easyrtcid of otherPeers
    resetView()
    $('.guest-available').removeClass 'hidden'
    $('#start-meeting-button').removeClass 'hidden'

#function to reset view to blank - hide only conditional elements
resetView = ->
  $('.connecting-to-server, .awaiting-guest, .guest-available, #leave-room-button, #start-meeting-button, #send-reminder-button, #end-meeting-button').addClass 'hidden'

performCall = (easyrtcid) ->
  easyrtc.call easyrtcid, callSuccessCB, callerrorCB, callAcceptCB

callSuccessCB = (easyrtcid) ->
  console.log "completed call to #{easyrtcid}"

callerrorCB = (errorMessage) ->
  console.log "err: #{errorMessage}"

callAcceptCB = (accepted, bywho) ->
  console.log "#{accepted ? 'accepted' : 'rejected'} by #{bywho}"

#ONCLICK FUNCTIONS FOR BUTTONS
loadOnClicks = ->
  $('#end-meeting-button').click ->
    occupants = easyrtc.getRoomOccupantsAsArray(shared.roomName)
    destination = occupants.filter(notMyself(easyrtc.myEasyrtcid))[0]
    console.log "Destination to send: #{destination}"
    easyrtc.sendPeerMessage destination, 'manualHangup', { hangup_method: 'button' }, ((msgType, msgBody) ->
      console.log 'manual hangup was sent'
    ), (errorCode, errorText) ->
      console.log 'Couldn\'t send hang up to peer'
    easyrtc.hangupAll()
    $('#end-call').submit()
  $('#leave-room-button').click ->
    if window.confirm('Are you sure you want to leave the chat room ?')
      window.location.assign '/mentoring'
  $('#send-reminder-button').click ->
    if window.confirm('Are you sure you want to send an SMS reminder to the guest ?')
      $.ajax(url: "/mentor_meetings/#{shared.meetingId}/reminder").done(->
        alert 'SMS sent'
        $('#send-reminder-button').addClass 'hidden'
      ).fail ->
        alert 'Could not sent SMS!'
  $('#start-meeting-button').click startMeeting

startMeeting = ->
  performCall getEasyrtcIdOfPeer()

getEasyrtcIdOfPeer = ->
  occupants = easyrtc.getRoomOccupantsAsArray(shared.roomName)
  occupants.filter(notMyself(easyrtc.myEasyrtcid))[0]

# CALLBACK FUNCTIONS
appSuccessCB = ->
  console.log 'App loaded successfully'

onCallCB = (easyrtcid, slot) ->
  console.log 'Call established'
  shared.callStarted = true
  $('#start-meeting').submit()
  # change meeting status
  resetView()
  $('#end-meeting-button').removeClass 'hidden'

hangUpCB = ->
  $('#end-meeting-button').addClass 'hidden'

$(document).ready ->
  initializer()
  loadOnClicks()
