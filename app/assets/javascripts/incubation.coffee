# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  if $("#startup_admin_attributes_is_student").length > 0
    if $("#startup_admin_attributes_is_student")[0].checked
      $('.startup_admin_roll_number').show()
    else
      $('.startup_admin_roll_number').hide()
$ ->
  $("#startup_admin_attributes_is_student").change ->
    $('.startup_admin_roll_number').toggle(this.checked);
