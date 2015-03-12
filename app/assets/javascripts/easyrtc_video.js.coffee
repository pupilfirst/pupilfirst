# Holder for shared settings.
shared = {
  occupants: 0
  manualPeerHangup: false
}

initializer = ->
  shared.callStarted = false
  shared.metInRoom = false
  loadChatData()
  easyrtc.setSocketUrl shared.chatData.data('easyrtc-socket-url')
  easyrtc.setRoomOccupantListener loggedInListener
  console.log "Entered room as: #{shared.userName}"
  easyrtc.setUsername shared.userName

  # Remove default close buttons on videos
  easyrtc.dontAddCloseButtons()

  # initialize easyrtc app
  easyrtc.easyApp shared.appName, 'self', [ 'guest' ], appSuccessCB
  easyrtc.setGotMedia gotMediaCB
  easyrtc.setGotConnection gotConnectionCB

  easyrtc.joinRoom shared.roomName
  easyrtc.setPeerListener hangupOnMsg, 'manualHangup'
  # listener for hangup message from guest
  easyrtc.setPeerListener chatListener, 'peerChat'
  # listener for chats from peer
  easyrtc.setOnCall onCallCB
  easyrtc.setOnHangup hangUpCB

# function to load chat data
loadChatData = ->
  shared.chatData = $('#chat-data')
  shared.appName = "SVMentoringEasyRTCApp"
  shared.roomName = "chatRoom#{shared.chatData.data('meeting-id')}"
  shared.userName = shared.chatData.data('current-user-name')
  shared.guestUserName = shared.chatData.data('guest-user-name')
  shared.reminderSent = shared.chatData.data('reminder-sent')
  shared.meetingId = shared.chatData.data('meeting-id')
  #load chat-box template and avatars
  shared.chatTemplate = $('#message-box-template')
  shared.selfAvatarUrl = shared.chatData.data('self-avatar-url')
  shared.guestAvatarUrl = shared.chatData.data('guest-avatar-url')
  shared.botAvatarUrl = shared.chatData.data('bot-avatar-url')
  shared.guestTitle = shared.chatData.data('guest-title')

# function to respond to manual hangup by peer
hangupOnMsg = (easyrtcid, msgType, msgData, targeting) ->
  console.log 'Manual hangup msg received'
  shared.manualPeerHangup = true
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
  if shared.occupants is 1
    return
  else
    shared.occupants = 1

  console.log 'Single occupancy in room'

  resetView()
  $('.awaiting-guest').removeClass 'hidden'

  if shared.metInRoom
    if shared.manualPeerHangup
      botPost "Your meeting has ended, please wait while you are redirected to the feedback page."
    else
      botPost "Seems like the #{shared.guestTitle} got disconnneted. Please wait for the #{shared.guestTitle} to reconnect."
  else
    botText = "It seems the #{shared.guestTitle} is yet to arrive."

    if shared.reminderSent
      $('#send-reminder-button').removeClass 'hidden'
      botText += " You may send the #{shared.guestTitle} a reminder SMS while you wait."

    botPost botText

multipleOccupancyView = (otherPeers) ->
  if shared.occupants is 2
    return
  else
    shared.occupants = 2

  shared.metInRoom = true
  botPost "The #{shared.guestTitle} is now available... "
  for easyrtcid of otherPeers
    resetView()
    $('#send-chat-button').removeClass 'disabled'
    $('.guest-available').removeClass 'hidden'
    $('#start-meeting-button').removeClass 'hidden'

#function to reset view to blank - hide only conditional elements
resetView = ->
  $('.connecting-to-server, .awaiting-guest, .guest-available, #start-meeting-button, #send-reminder-button, #end-meeting-button').addClass 'hidden'

performCall = (easyrtcid) ->
  easyrtc.call easyrtcid, callSuccessCB, callerrorCB, callAcceptCB

# function to respond to chats from peer
chatListener = (easyrtcid, msgType, msgData, targeting) ->
  addToConversation("guest",msgData)

addToConversation = (who,text) ->
  newChat = shared.chatTemplate.clone()
  newChat.find('.message-box').find('.message>span').html(text) 
  time = new Date();
  newChat.find('.message-box').find('.picture>span').html(time.getHours() + ":" + time.getMinutes())
  switch who
    when "self" 
      avatarUrl = shared.selfAvatarUrl
      altText = getInitials(shared.userName)
    when "guest" 
      avatarUrl = shared.guestAvatarUrl
      altText = getInitials(shared.guestUserName)
    else 
      avatarUrl = shared.botAvatarUrl
      altText = "BOT"
  if avatarUrl
    newChat.find('.message-box').find('.picture').find('.image').children()[0].src = avatarUrl
  else
    newChat.find('.message-box').find('.picture').find('.image').addClass('hidden')
    newChat.find('.message-box').find('.picture').find('.initial').html(altText)
    newChat.find('.message-box').find('.picture').find('.initial').removeClass('hidden')
  $('#chat-body').append(newChat)
  newChat.removeClass 'hidden'
  $("#chat-body").animate({scrollTop:$("#chat-body")[0].scrollHeight}, 1000);

botPost = (message) ->
  addToConversation("bot",message)

getInitials = (fullname) ->
  fullname.split(' ').map((s) ->
    s.charAt 0
  ).join('').toUpperCase().substr(0,2)

callSuccessCB = (easyrtcid) ->
  console.log "completed call to #{easyrtcid}"

callerrorCB = (errorMessage) ->
  console.log "err: #{errorMessage}"

callAcceptCB = (accepted, bywho) ->
  console.log "#{accepted ? 'accepted' : 'rejected'} by #{bywho}"

gotMediaCB = ->
  console.log "Local media initialized"
  botPost "Connecting to server..."

gotConnectionCB = ->
  console.log "Connected to server"

#ONCLICK FUNCTIONS FOR BUTTONS
loadOnClicks = ->
  $('#end-meeting-button').click endMeeting
  $('#send-reminder-button').click sendReminder
  $('#start-meeting-button').click startMeeting
  $('#send-chat-button').click sendChat

  #SEND CHAT ON HITTING ENTER
  $('#chat-to-send').keyup (e) ->
    key = e.which
    if key == 13 and shared.metInRoom
      $('#send-chat-button').click()

endMeeting = ->
  occupants = easyrtc.getRoomOccupantsAsArray(shared.roomName)
  destination = occupants.filter(notMyself(easyrtc.myEasyrtcid))[0]
  console.log "Destination to send: #{destination}"
  easyrtc.sendPeerMessage destination, 'manualHangup', { hangup_method: 'button' }, ((msgType, msgBody) ->
    console.log 'manual hangup was sent'
  ), (errorCode, errorText) ->
    console.log 'Couldn\'t send hang up to peer'
  easyrtc.hangupAll()
  $('#end-call').submit()

sendReminder = ->
  if window.confirm("Are you sure you want to send an SMS reminder to the #{shared.guestTitle}?")
    $.ajax(url: "/mentor_meetings/#{shared.meetingId}/reminder").done(->
      alert 'SMS sent'
      $('#send-reminder-button').addClass 'hidden'
    ).fail ->
      alert 'Could not sent SMS!'

sendChat = ->
  msgData = $('#chat-to-send')[0].value
  return if msgData.replace(/\s/g, "").length == 0
  easyrtc.sendPeerMessage(getEasyrtcIdOfPeer(), "peerChat", msgData, chatSuccessCB, chatFailureCB)
  addToConversation("self",msgData)
  $('#chat-to-send')[0].value = ""

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

  $('#note-over-guest-video').addClass 'hidden'
  $('#end-meeting-button').removeClass 'hidden'

hangUpCB = ->
  $('#end-meeting-button').addClass 'hidden'

chatSuccessCB = ->
  console.log 'chat sent successfully'

chatFailureCB = ->
  console.log 'chat failed'

$(document).ready ->
  initializer()
  loadOnClicks()
