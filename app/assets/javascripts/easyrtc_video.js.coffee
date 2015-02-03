# Some globally used variables.
callStarted = false
chatData = null
roomName = null

# Load data attributes from page (should be done after page loads).
loadData = ->
  chatData = $("#chat-data")
  roomName = $("#mentor-meeting-container").data("id") + "chatroom"

# Listener for hangup message from guest.
hangupPeerListener = (easyrtcid, msgType, msgData, targeting) ->
  console.log("Manual hangup msg received")
  easyrtc.hangupAll()
  $("#endcall").submit()

easyAppSuccessHandler = ->
  console.log("App loaded successfully")

# This is the main call handler.
#
# TODO: This method is OBESE. Move logic out into other functions. Chain functions if actions are linear.
callHandler = (easyrtcid, slot) ->
  console.log('setOnCall called')
  callStarted = true
  $('#start-meeting').submit() # change meeting status
  strong = $('#awaitingnotification')
  button = $('#startbutton')
  reminder_button = $('#reminderbutton')

  if reminder_button
    reminder_button.remove()

  strong.remove()
  button.remove()

  # creating hang up button
  hangupdiv =  $('#belowvideo')
  hangupbutton = document.createElement('button')
  hangupbutton.setAttribute("id", "hangupbutton")

  hangupbutton.onclick = ->
    occupants = easyrtc.getRoomOccupantsAsArray(roomName)
    destination = occupants.filter(notmyself(easyrtc.myEasyrtcid))[0]
    console.log("Destination to send: " + destination)

    # TODO: Anonymous functions as method arguments. Extract!
    easyrtc.sendPeerMessage(
      destination,
      'manual_hangup',
      {hangup_method:'button'},
      ((msgType, msgBody ) -> console.log("manual hangup was sent")),
      ((errorCode, errorText) -> console.log("Couldn't send hang up to peer"))
    )

    easyrtc.hangupAll()
    $("#endcall").submit()

  hanguplabel = document.createTextNode("End Meeting")
  hangupbutton.appendChild(hanguplabel)
  hangupdiv.appendChild(hangupbutton)

# function to return peer id when used with filter
#
# TODO: What is this method doing? I can't figure it out. Why a nested method? - Hari.
notmyself = (myid) ->
  return (element) ->
    return element != myid

# TODO: Another obese method.
loggedInListener = (roomName, otherPeers) ->
  otherClientDiv = $('#otherClients')

  # TODO: Execution breaks here. I am unable to proceed because I can't figure out which element this code block is deleting, or why it is doing so - Hari.
  # TODO: Use jquery's http://api.jquery.com/has/ and http://api.jquery.com/children/
  while otherClientDiv.hasChildNodes()
    otherClientDiv.removeChild(otherClientDiv.lastChild)

  console.log("Occupants: " + easyrtc.getRoomOccupantsAsArray(roomName))

  if easyrtc.getRoomOccupantsAsArray(roomName).length == 1
    console.log("Awaiting guest to join...")

    strong = document.createElement("strong")
    strong.setAttribute("id", "awaitingnotification")
    notification = document.createTextNode("Awaiting guest to join...")
    strong.appendChild(notification)
    otherClientDiv.appendChild(strong)
    leavebutton = document.createElement('button')
    leavebutton.setAttribute("id", "leavebutton")
    label = document.createTextNode("Come back later")
    leavebutton.appendChild(label)
    otherClientDiv.appendChild(leavebutton)

    # TODO: This should probably be replaced with a jQuery .click() handler method setter. http://api.jquery.com/click/
    leavebutton.onclick = ->
      if window.confirm("Are you sure you want to leave the chat room?")
        window.location.assign("/mentoring")

    if !callStarted && !chatData.data("reminder-sent")
      reminderbutton = document.createElement('button')
      reminderbutton.setAttribute("id", "reminderbutton")
      reminderdiv = $('#belowvideo')
      label = document.createTextNode("Send reminder")
      reminderbutton.appendChild(label)
      reminderdiv.appendChild(reminderbutton)

      # TODO: Another onclick that should be replaced with jQuery .click(). http://api.jquery.com/click/
      reminderbutton.onclick = ->
        if window.confirm("Are you sure you want to send an SMS reminder to the guest?")
          $.ajax({
            url: "/mentor_meetings/#{$("#mentor-meeting-container").data("id")}/reminder"
          }).done(() ->
            alert('SMS sent')
            reminderbutton.remove()
          ).fail(() ->
            alert('Could not sent SMS!')
          )
  else
    for easyrtcid in otherPeers
      do (easyrtcid) ->
        strong = document.createElement("strong")
        strong.setAttribute("id", "awaitingnotification")
        notification = document.createTextNode("#{easyrtc.idToName(easyrtcid)} is available now!")
        strong.appendChild(notification)
        otherClientDiv.appendChild(strong)
        button = document.createElement('button')
        button.setAttribute("id", "startbutton")

        button.onclick = ->
          performCall(easyrtcid)

        label = document.createTextNode("Start Meeting")
        button.appendChild(label)
        otherClientDiv.appendChild(button)

# TODO: Instead of passing the anonymous functions directly to the method, extract and name then, so that readers of code can understand what is being passed.
performCall = (easyrtcid) ->
  easyrtc.call(
    easyrtcid,
    ((easyrtcid) -> console.log("completed call to " + easyrtcid)),
    ((errorMessage) -> console.log("err:" + errorMessage)),
    ((accepted, bywho) -> console.log((accepted?"accepted":"rejected")+ " by " + bywho))
  )

# TODO: This method should be small, i.e., contain  no logic, since that is what a 'ready handler' should do.
# TODO: Maybe wrap some of the easyRTC methods in another method to logically separate?
documentReadyHandler = ->
  loadData()

  console.log(chatData.data("reminder-sent"))

  # Set socket URL for EasyRTC
  easyrtc.setSocketUrl(chatData.data("easyrtc-socket-url"))

  easyrtc.setRoomOccupantListener(loggedInListener)

  console.log("Name read: " + chatData.data("current-user-name"))
  easyrtc.setUsername(chatData.data("current-user-name"))

  easyrtc.dontAddCloseButtons()

  easyAppName = $("#mentor-meeting-container").data("id")+"easyrtcapp"

  easyrtc.easyApp(easyAppName, "self", ["caller"], easyAppSuccessHandler)

  easyrtc.joinRoom(roomName)

  # Set hangupPeerListener for 'manual_hangup' event.
  easyrtc.setPeerListener(hangupPeerListener, 'manual_hangup')

  # Set the call handler.
  easyrtc.setOnCall(callHandler)

  easyrtc.setOnHangup(
    (easyrtcid, slot) ->
      button = $('#hangupbutton')
      button.remove()
  )

$(document).ready(documentReadyHandler)
