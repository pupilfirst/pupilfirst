$(document).ready(function() {
  // When the Changeset button is clicked on the dashboard, reveal the changeset div and insert relevant changeset into it.
  $('button.papertrail_changeset').click(function() {
    $("#papertrail_changeset").css('display', 'inherit');
    $("#papertrail_changeset_pre").html(JSON.stringify(JSON.parse(this.getAttribute('changeset')), null, 4));
  });

  // When is_contact is checked, make sure that phone number is set to verified, and an invitation token is set.
  $('.formtastic.user').submit(function() {
    if($('input#user_is_contact').prop('checked')) {
      $('input#user_phone_verified').prop('checked', true);

      var invitation_token = $('input#user_invitation_token');

      // Set invitation token only if it isn't set already, and user isn't registered.
      if(!invitation_token.val() && !invitation_token.data('registered')) {
        invitation_token.val(Math.random().toString(36).slice(2));
      }
    }
  });
});
