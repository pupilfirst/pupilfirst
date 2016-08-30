handleTargetChanges = ->
  $('#s2id_vocalist_ping_founders #s2id_autogen3').focus () ->
    clearSelection($('#vocalist_ping_startups')) if $('#vocalist_ping_startups').val()
    clearSelection($('#vocalist_ping_channel')) if $('#vocalist_ping_channel').val()

  $('#s2id_vocalist_ping_startups #s2id_autogen2').focus () ->
    clearSelection($('#vocalist_ping_founders')) if $('#vocalist_ping_founders').val()
    clearSelection($('#vocalist_ping_channel')) if $('#vocalist_ping_channel').val()

  $('#s2id_vocalist_ping_channel #s2id_autogen1').focus () ->
    clearSelection($('#vocalist_ping_founders')) if $('#vocalist_ping_founders').val()
    clearSelection($('#vocalist_ping_startups')) if $('#vocalist_ping_startups').val()

clearSelection = (element) ->
  element.val(null).trigger('change')

$(document).on 'page:change', handleTargetChanges
