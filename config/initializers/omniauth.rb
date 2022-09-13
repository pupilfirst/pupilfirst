# This setting is acceptable only as long as we continue to temporarily use OAuth info
# for the purpose of authentication. If we ever "connect" a third-party account to our
# user account, we will need to remove this setting and use the default of POST-only.
#
# See https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2015-9284 for more information.
#
OmniAuth.config.allowed_request_methods = %i[get post]
