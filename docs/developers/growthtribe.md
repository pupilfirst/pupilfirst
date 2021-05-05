z# Growth Tribe Development Settings

# Development's environments setup

Prerequisities:
* Ruby: 2.7.3
* Docker
* (optional) puma-dev (https://github.com/puma/puma-dev)
  * `brew install puma/puma/puma-dev`
  * `puma-dev -install -d test:localhost`
  * `puma-dev -setup -d test:localhost`

Setup:
* clone https://github.com/growthtribeacademy/pupilfirst
* run: `docker compose up -d`
* run: `make install` (or `make dev` if you have not installed puma-dev)
* setup Overcommit as described [here](https://developers.pupilfirst.com/docs/development_setup#setup-overcommit)

## Keycloak

### Changes that override Keycloaks behavior!

#### Removal of registration link from the login page

To **not** allow registration of users for only a single Keycloak client, growthtribe_theme login page has a javascript that will remove the registration button created by keycloak for the login page if it's `redirect_uri` matches `https://lms.growthtribe.io`.
If you want to have registration link available on LMS login page, you will need to remove a setting from the [custom keycloak image](https://github.com/growthtribeacademy/gt-keycloak-image) and re-deploy it to production.
The property that controls this behavior, `eraseRegBtnRedirectUrl` is found on `gt-keycloak-image/growthtribe_theme/login/theme.property`. Remove it and this will disable the script allowing the LMS login page to have the registration link according to Keycloak settings.
