//= require rails-ujs

//= require jquery3
//= require popper
//= require bootstrap

//= require turbolinks
//= require turbolinks_compatibility

// Require PNotify (rails asset), unobtrusive flash (rubygems), and flashes (local code) early so that notifications
// render as quickly as possible.
// TODO: Remove require pnotify/pnotify.js when possible.
// The extra require is needed to avoid issue with incorrect require-order in main file.
//= require pnotify/pnotify.js
//= require pnotify
//= require flashes
//= require unobtrusive_flash

// XDAN's datetimepicker
//= require datetimepicker
//= require xdan_datetimepicker

//= require moment
//= require select2-full
//= require google_tag_manager
//= require youtube
//= require limit_max_int
//= require inspectlet
//= require video
//= require jquery.scrollTo
//= require jquery-stickit
//= require ahoy
//= require jspdf
//= require lodash

// Rails assets
//= require intro.js/intro.js
//= require perfect-scrollbar
//= require slick-carousel/slick.js
//= require waypoints/jquery.waypoints.js
//= require waypoints
//= require typedjs
//= require jquery.counterup

// Environment specific
//= require test

// Shared
//= require _shared
//= require navbar
//= require footer

// Components
//= require components

// Controller-specific
//= require home
//= require about
//= require startups
//= require talent
//= require admissions
//= require faculty
//= require founders
//= require story
//= require resources
//= require users
//= require product_metrics
//= require intercom_settings
