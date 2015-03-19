$(document).ready(function() {
  // When the Changeset button is clicked on the dashboard, reveal the changeset div and insert relevant changeset into it.
  $('button.papertrail_changeset').click(function() {
    $("#papertrail_changeset").css('display', 'inherit');
    $("#papertrail_changeset_pre").html(JSON.stringify(JSON.parse(this.getAttribute('changeset')), null, 4));
  });
});
