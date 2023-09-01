# Allow GET requests in addition to POST requests for OmniAuth callbacks, and
# also silence the warning related to CVE-2015-9284. We have custom mitigation
# for the vulnerability.
OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true
