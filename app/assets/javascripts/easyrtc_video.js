function my_init() {

  call_started = false;

  easyrtc.setSocketUrl(":4000"); //change this to reflect location of node server

  easyrtc.setRoomOccupantListener(loggedInListener);

  console.log("Name read:" + $("#self").data("name"));
  easyrtc.setUsername($("#self").data("name"));

  easyrtc.dontAddCloseButtons();

  easyrtc.easyApp($("#mentor-meeting-container").data("id")+"chatroom", "self", ["caller"],
    function(myId) {
      console.log("App loaded succesfully");
    });

  // listener for hangup message from guest
  easyrtc.setPeerListener( function(easyrtcid, msgType, msgData, targeting){
    console.log("Manual hangup msg received");
    easyrtc.hangupAll();
    $("#endcall").submit(); 
    },'manual_hangup');

  easyrtc.setOnCall( function(easyrtcid, slot) {
    console.log('setOnCall called');
    call_started = true;
    $('#callstart').submit(); // change meeting status
    strong = document.getElementById('awaitingnotification');
    button = document.getElementById('startbutton');
    reminderbutton = document.getElementById('reminderbutton');
    if (reminderbutton) {reminderbutton.remove();};
    strong.remove();
    button.remove();
    
    // creating hang up button
      hangupdiv =  document.getElementById('belowvideo');
      var hangupbutton = document.createElement('button');
      hangupbutton.setAttribute("id", "hangupbutton");
      hangupbutton.onclick = function() {
        occupants = easyrtc.getRoomOccupantsAsArray("default"); //because default room name is 'default'
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
  });


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


function loggedInListener(roomName, otherPeers) {
  var otherClientDiv = document.getElementById('otherClients');
  while (otherClientDiv.hasChildNodes()) {
    otherClientDiv.removeChild(otherClientDiv.lastChild);
  }

  console.log("Occupants: " + easyrtc.getRoomOccupantsAsArray(roomName));

  if (easyrtc.getRoomOccupantsAsArray(roomName).length === 1){
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
    if (!call_started){
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

$(document).ready(my_init)
$(document).on('page:load', my_init)

