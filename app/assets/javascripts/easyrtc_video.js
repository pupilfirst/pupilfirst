function my_init() {
  easyrtc.setSocketUrl(":4000");
  easyrtc.setRoomOccupantListener(loggedInListener);
  console.log("Name read:" + $("#self").data("name"));
  easyrtc.setUsername($("#self").data("name"));
  // dontAddCloseButtons();
  easyrtc.easyApp($("#mentor-meeting-container").data("id")+"chatroom", "self", ["caller"],
    function(myId) {
      console.log("My easyrtcid is " + myId);
    });
}


function loggedInListener(roomName, otherPeers) {
  var otherClientDiv = document.getElementById('otherClients');
  while (otherClientDiv.hasChildNodes()) {
    otherClientDiv.removeChild(otherClientDiv.lastChild);
  }
  console.log("Occupant array length = " + easyrtc.getRoomOccupantsAsArray(roomName).length);
  if (easyrtc.getRoomOccupantsAsArray(roomName).length === 1){
    console.log("Awaiting guest to join...");
    strong = document.createElement("strong");
    notification = document.createTextNode("Awaiting guest to join...");
    strong.appendChild(notification);
    otherClientDiv.appendChild(strong);
  }
  else {
    for(var easyrtcid in otherPeers) {
      strong = document.createElement("strong");
      notification = document.createTextNode(easyrtc.idToName(easyrtcid)+" is available now !");
      strong.appendChild(notification);
      otherClientDiv.appendChild(strong);
      var button = document.createElement('button');
      button.onclick = function() {
        performCall(easyrtcid);
      }
      // button.onclick = function(easyrtcid) {
      //   return function() {
      //     performCall(easyrtcid);
      //   }
      // }(i);
      // console.log(easyrtcid);
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


