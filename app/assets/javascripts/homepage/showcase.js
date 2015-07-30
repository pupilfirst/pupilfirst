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
    modal.find('.modal-body img').attr('src', timeline);
  })
  $('#showcase-timeline').on('hidden.bs.modal', function(event) {
    var modal = $(this);
    modal.find('.modal-body img').attr('src', '');
  })
}

$(document).ready(showcaseEmbeds);