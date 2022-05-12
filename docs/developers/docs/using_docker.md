---
id: docker
title: Deploying using Docker
sidebar_label: Using Docker
---

Docker images for the LMS can be found on [our official Docker Hub account: pupilfirst/pupilfirst](https://hub.docker.com/r/pupilfirst/pupilfirst).

These images are automatically built using Github CI on [our Github repo](https://github.com/pupilfirst/pupilfirst).

These images are ideal for quickly and easily deploying the LMS to targets such as
[Digital Ocean's App Platform](https://www.digitalocean.com/products/app-platform).

## Environment variables

There are several environment variables you'll need to set up to get the application fully functional:

### Essential

#### Basic configuration

```
ASSET_HOST=https://fully-qualified.domain-name.com
DATABASE_URL=postgresql://username:password@host:port/database?sslmode=require
DEFAULT_SENDER_EMAIL_ADDRESS=noreply@domain-name.com
GRAPH_API_RATE_LIMIT=10
I18N_AVAILABLE_LOCALES=en,ru
I18N_DEFAULT_LOCALE=en
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
SECRET_KEY_BASE=generate_using_rails_secret
```

#### Postmark

```
POSTMARK_API_TOKEN
POSTMARK_HOOK_ID
POSTMARK_HOOK_SECRET
```

Generate these variables using [these instructions](/docs/heroku#sending-emails-with-postmark).

#### AWS

```
AWS_ACCESS_KEY_ID=access_key_id_from_aws
AWS_SECRET_ACCESS_KEY=secret_access_key_from_aws
AWS_REGION=bucket_region_name
AWS_BUCKET=bucket_name_from_aws
```

Generate these variables using [these instructions](/docs/heroku#file-storage-using-aws).

#### Google Recaptcha

```
RECAPTCHA_V3_SITE_KEY
RECAPTCHA_V3_SECRET_KEY
RECAPTCHA_V2_SITE_KEY
RECAPTCHA_V2_SECRET_KEY
```

Generate these variables using [these instructions](/docs/heroku#sending-emails-with-postmark).

#### Webpush Notifications

```
VAPID_PUBLIC_KEY
VAPID_PRIVATE_KEY
```



Generate these variables using [these instructions](/docs/heroku#webpush-notifications).
Set all essential environment variables before deploying

### Database setup

```
bundle exec rails db:schema:load
bundle exec rails db:seed
```
### Set Up Super Admin User

```
bundle exec rails c - e p 
user = User.find_by(email: 'admin@example.com')
user.update!(
  password: 'a secure password',
  password_confirmation: 'a secure password',
)
```
### Set a primary domain, still on the rails console as in heroku deployment 

```
School.first.domains.create!(fqdn: 'my-app-name.herokuapp.com', primary: true)
```

### To allow background tasks set up service workers as [here](https://docs.digitalocean.com/products/app-platform/how-to/manage-workers/) then input the command shown below 
### Remember to change from Web service
```
bin/worker
```

### For above if app environments were not set in app, set the same in this component 
### Optional


#### Cloudfront

```
CLOUDFRONT_PRIVATE_KEY_BASE_64_ENCODED=cloudfront_private_key_from_aws
CLOUDFRONT_HOST=cloudfront_host_from_aws
CLOUDFRONT_KEY_PAIR_ID=cloudfront_key_pair_id_from_aws
CLOUDFRONT_EXPIRY=expiry_in_seconds
```

Generate these variables using [these instructions](/docs/heroku#content-delivery-network).

#### Sign in with OAuth

```
GOOGLE_OAUTH2_CLIENT_ID
GOOGLE_OAUTH2_CLIENT_SECRET
FACEBOOK_KEY
FACEBOOK_SECRET
GITHUB_KEY
GITHUB_SECRET
```

Generate these variables using [these instructions](/docs/heroku#signing-in-with-oauth).

#### Rollbar

```
ROLLBAR_CLIENT_TOKEN
ROLLBAR_SERVER_TOKEN
```


