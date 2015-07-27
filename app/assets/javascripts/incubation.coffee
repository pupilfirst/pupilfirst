# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#startup_admin_attributes_is_student").change ->
    console.log 'is_founder changed'
    $('.startup_admin_roll_number').toggle(this.checked);
    return
