# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: '_sv_dot_co_session', domain: {
  production: Rails.application.secrets.cookie_domain
}.fetch(Rails.env.to_sym, :all)
