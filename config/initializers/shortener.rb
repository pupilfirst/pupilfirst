# Configs for the 'shortener' gem : https://github.com/jpmcgrath/shortener

Shortener.default_redirect = "/404" # an ugly hack to prevent the gem from messing up with 404s

Shortener.forbidden_keys.concat %w(admin founder startups about faculty library talent apply transparency timeline ahoy)
