// declaring global variables
var callStarted,chatData,appName,roomName,userName,reminderSent,meetingId;

function initializer() {
  callStarted = false;
  loadChatData();
  easyrtc.setSocketUrl(chatData.data("easyrtc-socket-url"));
  easyrtc.setRoomOccupantListener(loggedInListener); 
  console.log("Entered room as: " + chatData.data("current-user-name"));  
  easyrtc.setUsername(userName);
  easyrtc.dontAddCloseButtons();// Remove default close buttons on videos
  easyrtc.easyApp(appName, "self", ["caller"],appSuccessCB);  // initialize easyrtc app
  easyrtc.joinRoom(roomName);
  easyrtc.setPeerListener( hangupOnMsg,'manualHangup');  // listener for hangup message from guest
  easyrtc.setOnCall(onCallCB);
  easyrtc.setOnHangup(hangUpCB);
}

// function to load chat data
function loadChatData() {
  chatData = $("#chat-data");
  appName = "appForMeeting" + chatData.data("meeting-id");
  roomName = "chatRoom" + chatData.data("meeting-id");
  userName = chatData.data("current-user-name");
  reminderSent = chatData.data("reminder-sent");
  meetingId = chatData.data("meeting-id");
};

// function to respond to manual hangup by peer
function hangupOnMsg(easyrtcid, msgType, msgData, targeting){
  console.log("Manual hangup msg received");
  easyrtc.hangupAll();
  $("#end-call").submit(); 
  }

// function to return peer id when used with filter
function notmyself(myId) {
  return function(element) {
      return element != myId;
  }
}

function loggedInListener(roomName, otherPeers) {
  console.log("easyrtcid of Occupants: " + easyrtc.getRoomOccupantsAsArray(roomName));
  if (easyrtc.getRoomOccupantsAsArray(roomName).length === 1){singleOccupancyView(otherPeers);}
  else {multipleOccupancyView(otherPeers);}
};

function singleOccupancyView(otherPeers){
  console.log("Single occupancy in room");
  resetView();
  $('#awaiting-guest').removeClass("hidden");
  $('#leave-room-button').removeClass("hidden");

  if (!callStarted && !reminderSent){
    $('#send-reminder-button').removeClass("hidden");
  };
}

function multipleOccupancyView(otherPeers){
  console.log("otherPeers:" + otherPeers)
  for(var easyrtcid in otherPeers) {
    resetView();
    $('#guest-available').removeClass("hidden");
    $('#start-meeting-button').removeClass("hidden");
  };
};

//function to reset view to blank - hide only conditional elements
function resetView () {
  $("#awaiting-guest ,#guest-available ,#leave-room-button ,#start-meeting-button ,#send-reminder-button ,#end-meeting-button").addClass("hidden");
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

//ONCLICK FUNCTIONS FOR BUTTONS

window.onload = function(){

  $('#end-meeting-button')[0].onclick = function() {
    occupants = easyrtc.getRoomOccupantsAsArray(roomName); 
    destination = occupants.filter(notmyself(easyrtc.myEasyrtcid))[0];
    console.log("Destination to send: " + destination);
    easyrtc.sendPeerMessage(destination, 'manualHangup', {hangup_method:'button'},
        function(msgType, msgBody ){
           console.log("manual hangup was sent");
        },
        function(errorCode, errorText){
           console.log("Couldn't send hang up to peer");
        }
    );
    easyrtc.hangupAll();
    $("#end-call").submit();   
  }

  $('#leave-room-button')[0].onclick = function(){
      if (window.confirm("Are you sure you want to leave the chat room ?")){
        window.location.assign("/mentoring")       }
    }

  $('#send-reminder-button')[0].onclick = function(){
    if (window.confirm("Are you sure you want to send an SMS reminder to the guest ?")){
      $.ajax({
        url: "/mentor_meetings/"+meetingId+"/reminder"
      })
      .done(function(){
        alert('SMS sent')
        $('#send-reminder-button').addClass("hidden");
      })
      .fail(function(){
        alert('Could not sent SMS!')
      });
      
    }
  }

  $('#start-meeting-button')[0].onclick = function(easyrtcid) {
    performCall(easyrtcid);
  } 
}

// CALLBACK FUNCTIONS

function appSuccessCB() {
    console.log("App loaded successfully");
  }

function onCallCB(easyrtcid, slot) {
  console.log('Call established');
  callStarted = true;
  $('#start-meeting').submit(); // change meeting status
  resetView();
  $('#end-meeting-button').removeClass("hidden");
};

function hangUpCB() {
  $('#end-meeting-button').addClass("hidden");
}


$(document).ready(initializer)
$(document).on('page:load', initializer)