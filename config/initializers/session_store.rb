# Be sure to restart your server when you modify this file.

Svapp::Application.config.session_store :cookie_store, key: '_svapp_session', domain: {
  production: '.sv.co'
}.fetch(Rails.env.to_sym, :all)
