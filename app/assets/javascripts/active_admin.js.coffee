#= require active_admin/base

#= require turbolinks
#= require turbolinks_compatibility

# External libraries
#= require react
#= require react_ujs

# TODO: Remove require pnotify/pnotify.js when possible.
# The extra require is needed to avoid issue with incorrect require-order in main file.
#= require pnotify/pnotify.js
#= require pnotify

#= require select2-full
#= require trix

# XDAN's datetimepicker
#= require datetimepicker
#= require xdan_datetimepicker

# Local files
#= require_tree ./admin
#= require jquery.sparkline.js

# IMPORTANT: Unobtrusive flash must be loaded AFTER flash event handlers are set, because of customization.
# See: https://github.com/harigopal/unobtrusive_flash/commit/24e7787d16db66f7956747444433a4e47278193a
#= require unobtrusive_flash

# Chartkick
#= require moment
#= require Chart-js
#= require chartkick
