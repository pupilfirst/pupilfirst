var showcaseEmbeds = function() {
  // Configure video modals
  $('#showcase-video').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget); // Button that triggered the modal
    var title = button.data('title');
    var video = button.data('video');
    var modal = $(this);
    modal.find('.modal-title').text(title);
    modal.find('.modal-body iframe').attr('src', video);
  })
  $('#showcase-video').on('hidden.bs.modal', function(event) {
    var modal = $(this);
    modal.find('.modal-body iframe').attr('src', '');
  })

  // Configure timeline modals
  $('#showcase-timeline').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget); // Button that triggered the modal
    var title = button.data('title');
    var timeline = button.data('timeline');
    var modal = $(this);
    modal.find('.modal-title').text(title);
    // TODO: Refactor using jQuery
    var image = document.createElement("img");
    image.src = timeline;
    image.setAttribute('class','img-responsive');
    image.setAttribute('id','timeline-image');
    var parent = document.getElementById("timeline-image-wrapper");
    parent.appendChild(image);
    $("#spinner-image").hide();
  });
  $('#showcase-timeline').on('hidden.bs.modal', function(event) {
    var modal = $(this);
    var parent = document.getElementById("timeline-image-wrapper");
    var child = document.getElementById("timeline-image");
    parent.removeChild(child);
    $("#spinner-image").show();
  })

  //Make the thumbnails trigger the right modal
  $('.showcase-activate').on('click', function(event) {
    var video = $(this).parent('.thumbnail').find('.showcase-video-trigger');
    var timeline = $(this).parent('.thumbnail').find('.showcase-timeline-trigger');
    if(video.length) {
      video.click();
    } else {
      timeline.click();
    }
    return false;
  })
}

$(document).ready(showcaseEmbeds);
