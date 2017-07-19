handleTargetChanges = ->
  $('#vocalist_ping_founders_input > .select2-container').click () ->
    clearSelection($('#vocalist_ping_startups')) if $('#vocalist_ping_startups').val()
    clearSelection($('#vocalist_ping_channel')) if $('#vocalist_ping_channel').val()
    clearSelection($('#vocalist_ping_levels')) if $('#vocalist_ping_levels').val()

  $('#vocalist_ping_startups_input > .select2-container').click () ->
    clearSelection($('#vocalist_ping_founders')) if $('#vocalist_ping_founders').val()
    clearSelection($('#vocalist_ping_channel')) if $('#vocalist_ping_channel').val()
    clearSelection($('#vocalist_ping_levels')) if $('#vocalist_ping_levels').val()

  $('#vocalist_ping_levels_input > .select2-container').click () ->
    clearSelection($('#vocalist_ping_founders')) if $('#vocalist_ping_founders').val()
    clearSelection($('#vocalist_ping_startups')) if $('#vocalist_ping_startups').val()
    clearSelection($('#vocalist_ping_channel')) if $('#vocalist_ping_channel').val()

  $('#vocalist_ping_channel_input > .select2-container').click () ->
    clearSelection($('#vocalist_ping_founders')) if $('#vocalist_ping_founders').val()
    clearSelection($('#vocalist_ping_startups')) if $('#vocalist_ping_startups').val()
    clearSelection($('#vocalist_ping_levels')) if $('#vocalist_ping_levels').val()

initializeSelect2s = ->
  $('#vocalist_ping_channel').select2(width: '300px');
  $('#vocalist_ping_startups').select2(width: '300px');
  $('#vocalist_ping_founders').select2(width: '300px');
  $('#vocalist_ping_levels').select2(width: '300px');

clearSelection = (element) ->
  element.val(null).trigger('change')

$(document).on 'turbolinks:load', ->
  if $('#new_vocalist_ping').length
    initializeSelect2s()
    handleTargetChanges()
