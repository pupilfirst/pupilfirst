function initializer() {
  call_started = false;
  chat_data = $("#chat-data");
  app_name = "app_for_meeting_" + chat_data.data("meeting-id");
  room_name = "Chatroom" + chat_data.data("meeting-id");
  user_name = chat_data.data("current-user-name");


  // Set socket URL for EasyRTC server
  easyrtc.setSocketUrl(chat_data.data("easyrtc-socket-url"));

  // Set event listener for change in room occupancy 
  easyrtc.setRoomOccupantListener(loggedInListener);

  // Set chatroom username for current user
  console.log("Entered room as: " + chat_data.data("current-user-name"));
  easyrtc.setUsername(user_name);

  // Remove default close buttons on videos
  easyrtc.dontAddCloseButtons();

  // initialize easyrtc app
  easyrtc.easyApp(app_name, "self", ["caller"],appsuccesscb);

  // Callback for succesfull app initialization
  function appsuccesscb() {
      console.log("App loaded successfully");
    }

  // join the corresponding room
  easyrtc.joinRoom(room_name);

  // listener for hangup message from guest
  easyrtc.setPeerListener( hangup_on_msg,'manual_hangup');

  // Responding to manual hangup by peer
  function hangup_on_msg(easyrtcid, msgType, msgData, targeting){
    console.log("Manual hangup msg received");
    easyrtc.hangupAll();
    $("#endcall").submit(); 
    }

  easyrtc.setOnCall(oncallcb);

  // Callback for succesfull call
  function oncallcb(easyrtcid, slot) {
    console.log('Call established');
    call_started = true;
    $('#start-meeting').submit(); // change meeting status
    $('awaitingnotification').remove();
    $('startbutton').remove();
    if ($(reminderbutton)) {reminderbutton.remove();}; 
    
    // creating hang up button
      hangupdiv =  document.getElementById('belowvideo');
      var hangupbutton = document.createElement('button');
      hangupbutton.setAttribute("id", "hangupbutton");
      hangupbutton.onclick = function() {
        occupants = easyrtc.getRoomOccupantsAsArray(room_name); 
        destination = occupants.filter(notmyself(easyrtc.myEasyrtcid))[0];
        console.log("Destination to send: " + destination);
        easyrtc.sendPeerMessage(destination, 'manual_hangup', {hangup_method:'button'},
            function(msgType, msgBody ){
               console.log("manual hangup was sent");
            },
            function(errorCode, errorText){
               console.log("Couldn't send hang up to peer");
            }
        );
        easyrtc.hangupAll();
        $("#endcall").submit();   
      }
      hanguplabel = document.createTextNode("End Meeting");
      hangupbutton.appendChild(hanguplabel);
      hangupdiv.appendChild(hangupbutton); 
  };


  easyrtc.setOnHangup( function(easyrtcid, slot) {
     button = document.getElementById('hangupbutton')
     button.remove();        
  });
}

// function to return peer id when used with filter
function notmyself(myid) {
  return function(element) {
      return element != myid;
  }
}


function loggedInListener(room_name, otherPeers) {
  var otherClientDiv = document.getElementById('otherClients');
  while (otherClientDiv.hasChildNodes()) {
    otherClientDiv.removeChild(otherClientDiv.lastChild);
  }

  console.log("Occupants: " + easyrtc.getRoomOccupantsAsArray(room_name));


  if (easyrtc.getRoomOccupantsAsArray(room_name).length === 1){
    console.log("Awaiting guest to join...");
    strong = document.createElement("strong");
    strong.setAttribute("id", "awaitingnotification");
    notification = document.createTextNode("Awaiting guest to join...");
    strong.appendChild(notification);
    otherClientDiv.appendChild(strong);
    leavebutton = document.createElement('button');
    leavebutton.setAttribute("id", "leavebutton");
    label = document.createTextNode("Come back later");
    leavebutton.appendChild(label);
    otherClientDiv.appendChild(leavebutton);
    leavebutton.onclick = function(){
        if (window.confirm("Are you sure you want to leave the chat room ?")){
          window.location.assign("/mentoring")       }
      }
    if (!call_started && !chat_data.data("reminder-sent")){
      reminderbutton = document.createElement('button');
      reminderbutton.setAttribute("id", "reminderbutton");
      reminderdiv = document.getElementById('belowvideo');
      label = document.createTextNode("Send reminder");
      reminderbutton.appendChild(label);
      reminderdiv.appendChild(reminderbutton);
      reminderbutton.onclick = function(){
        if (window.confirm("Are you sure you want to send an SMS reminder to the guest ?")){
          $.ajax({
            url: "/mentor_meetings/"+$("#mentor-meeting-container").data("id")+"/reminder"
          })
          .done(function(){
            alert('SMS sent')
            reminderbutton.remove();
          })
          .fail(function(){
            alert('Could not sent SMS!')
          });
          
        }
      }
    }

  }
  else {
    for(var easyrtcid in otherPeers) {
      strong = document.createElement("strong");
      strong.setAttribute("id", "awaitingnotification");
      notification = document.createTextNode(easyrtc.idToName(easyrtcid)+" is available now !");
      strong.appendChild(notification);
      otherClientDiv.appendChild(strong);
      button = document.createElement('button');
      button.setAttribute("id", "startbutton");
      button.onclick = function() {
        performCall(easyrtcid);
      }
      label = document.createTextNode("Start Meeting");
      button.appendChild(label);
      otherClientDiv.appendChild(button); 
    }
  }
}


function performCall(easyrtcid) {
  easyrtc.call(
    easyrtcid,
    function(easyrtcid) { console.log("completed call to " + easyrtcid);},
    function(errorMessage) { console.log("err:" + errorMessage);},
    function(accepted, bywho) {
      console.log((accepted?"accepted":"rejected")+ " by " + bywho);
    }
    );
}

$(document).ready(initializer)
$(document).on('page:load', initializer)