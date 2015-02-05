# declaring global variables
callStarted = undefined
chatData = undefined
appName = undefined
roomName = undefined
userName = undefined
reminderSent = undefined
meetingId = undefined

initializer = ->
  callStarted = false
  loadChatData()
  easyrtc.setSocketUrl chatData.data('easyrtc-socket-url')
  easyrtc.setRoomOccupantListener loggedInListener
  console.log 'Entered room as: ' + chatData.data('current-user-name')
  easyrtc.setUsername userName
  easyrtc.dontAddCloseButtons()
  # Remove default close buttons on videos
  easyrtc.easyApp appName, 'self', [ 'caller' ], appSuccessCB
  # initialize easyrtc app
  easyrtc.joinRoom roomName
  easyrtc.setPeerListener hangupOnMsg, 'manualHangup'
  # listener for hangup message from guest
  easyrtc.setOnCall onCallCB
  easyrtc.setOnHangup hangUpCB
  return

# function to load chat data
loadChatData = ->
  chatData = $('#chat-data')
  appName = 'appForMeeting' + chatData.data('meeting-id')
  roomName = 'chatRoom' + chatData.data('meeting-id')
  userName = chatData.data('current-user-name')
  reminderSent = chatData.data('reminder-sent')
  meetingId = chatData.data('meeting-id')
  return

# function to respond to manual hangup by peer
hangupOnMsg = (easyrtcid, msgType, msgData, targeting) ->
  console.log 'Manual hangup msg received'
  easyrtc.hangupAll()
  $('#end-call').submit()
  return

# function to return peer id when used with filter
notMyself = (myId) ->
  (element) ->
    element != myId

loggedInListener = (roomName, otherPeers) ->
  console.log 'easyrtcid of Occupants: ' + easyrtc.getRoomOccupantsAsArray(roomName)
  if easyrtc.getRoomOccupantsAsArray(roomName).length == 1
    singleOccupancyView otherPeers
  else
    multipleOccupancyView otherPeers
  return

singleOccupancyView = (otherPeers) ->
  console.log 'Single occupancy in room'
  resetView()
  $('#awaiting-guest').removeClass 'hidden'
  $('#leave-room-button').removeClass 'hidden'
  if !callStarted and !reminderSent
    $('#send-reminder-button').removeClass 'hidden'
  return

multipleOccupancyView = (otherPeers) ->
  for easyrtcid of otherPeers
    resetView()
    $('#guest-available').removeClass 'hidden'
    $('#start-meeting-button').removeClass 'hidden'
  return

#function to reset view to blank - hide only conditional elements
resetView = ->
  $('#awaiting-guest ,#guest-available, #leave-room-button, #start-meeting-button, #send-reminder-button, #end-meeting-button').addClass 'hidden'
  return

performCall = (easyrtcid) ->
  easyrtc.call easyrtcid, callSuccessCB, callerrorCB, callAcceptCB
  return

callSuccessCB = (easyrtcid) ->
  console.log 'completed call to ' + easyrtcid
  return

callerrorCB = (errorMessage) ->
  console.log 'err:' + errorMessage
  return

callAcceptCB = (accepted, bywho) ->
  console.log (if accepted then 'accepted' else 'rejected') + ' by ' + bywho
  return

#ONCLICK FUNCTIONS FOR BUTTONS
loadOnClicks = ->
  $('#end-meeting-button').click ->
    occupants = easyrtc.getRoomOccupantsAsArray(roomName)
    destination = occupants.filter(notMyself(easyrtc.myEasyrtcid))[0]
    console.log 'Destination to send: ' + destination
    easyrtc.sendPeerMessage destination, 'manualHangup', { hangup_method: 'button' }, ((msgType, msgBody) ->
      console.log 'manual hangup was sent'
      return
    ), (errorCode, errorText) ->
      console.log 'Couldn\'t send hang up to peer'
      return
    easyrtc.hangupAll()
    $('#end-call').submit()
    return
  $('#leave-room-button').click ->
    if window.confirm('Are you sure you want to leave the chat room ?')
      window.location.assign '/mentoring'
    return
  $('#send-reminder-button').click ->
    if window.confirm('Are you sure you want to send an SMS reminder to the guest ?')
      $.ajax(url: '/mentor_meetings/' + meetingId + '/reminder').done(->
        alert 'SMS sent'
        $('#send-reminder-button').addClass 'hidden'
        return
      ).fail ->
        alert 'Could not sent SMS!'
        return
    return
  $('#start-meeting-button').click (easyrtcid) ->
    performCall easyrtcid
    return
  return

# CALLBACK FUNCTIONS
appSuccessCB = ->
  console.log 'App loaded successfully'
  return

onCallCB = (easyrtcid, slot) ->
  console.log 'Call established'
  callStarted = true
  $('#start-meeting').submit()
  # change meeting status
  resetView()
  $('#end-meeting-button').removeClass 'hidden'
  return

hangUpCB = ->
  $('#end-meeting-button').addClass 'hidden'
  return

$(document).ready ->
  initializer()
  loadOnClicks()
  return
