$(document).ready(function() {
  $('button.papertrail_changeset').click(function() {
    $("#papertrail_changeset").css('display', 'inherit');
    $("#papertrail_changeset_pre").html(JSON.stringify(JSON.parse(this.getAttribute('changeset')), null, 4));
  });
});
