Hubspot.configure(
  client_id: Rails.application.secrets.hubspot[:client_id],
  client_secret: Rails.application.secrets.hubspot[:client_secret],
  redirect_uri: "https://staging.growthtribe.nl/oauth",
  hapikey: Rails.application.secrets.hubspot[:api_key]
)