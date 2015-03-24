# Custom Logging

This application performs custom logging with the following format:

    Rails.llog.info event: :event_name, extra: :params

## Events

### Mentoring

* `mentor_signup` - Mentor has successfully signed up via the front end.

### SMS

* `sms_approved_startups_without_agreement` - Daily SMS.

### Reminders

* `agreement_expiry_mail` - Mail has been sent to startup (founders) indicating impending expiry of their agreement with SV.

### Contacting users

* `user_push_notify` - A push notification has been sent to a (single) user.
