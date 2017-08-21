handleTargetChanges = ->
  $('#vocalist_ping_founders').on 'select2:select', () ->
    clearSelection($('#vocalist_ping_startups')) if $('#vocalist_ping_startups').val()
    clearSelection($('#vocalist_ping_channel')) if $('#vocalist_ping_channel').val()
    clearSelection($('#vocalist_ping_levels')) if $('#vocalist_ping_levels').val()

  $('#vocalist_ping_startups').on 'select2:select', () ->
    clearSelection($('#vocalist_ping_founders')) if $('#vocalist_ping_founders').val()
    clearSelection($('#vocalist_ping_channel')) if $('#vocalist_ping_channel').val()
    clearSelection($('#vocalist_ping_levels')) if $('#vocalist_ping_levels').val()

  $('#vocalist_ping_levels').on 'select2:select', () ->
    clearSelection($('#vocalist_ping_founders')) if $('#vocalist_ping_founders').val()
    clearSelection($('#vocalist_ping_startups')) if $('#vocalist_ping_startups').val()
    clearSelection($('#vocalist_ping_channel')) if $('#vocalist_ping_channel').val()

  $('#vocalist_ping_channel').on 'select2:select', () ->
    clearSelection($('#vocalist_ping_founders')) if $('#vocalist_ping_founders').val()
    clearSelection($('#vocalist_ping_startups')) if $('#vocalist_ping_startups').val()
    clearSelection($('#vocalist_ping_levels')) if $('#vocalist_ping_levels').val()

initializeSelect2s = ->
  $('#vocalist_ping_channel').select2(width: '300px');
  $('#vocalist_ping_levels').select2(width: '300px');

setupSelect2ForFounder = ->
  userInput = $('#vocalist_ping_founders')

  if userInput.length > 0
    userInput.select2
      width: '300px',
      placeholder: 'Search by Name',
      minimumInputLength: 3,
      ajax:
        url: '/admin/founders/search_founder',
        dataType: 'json',
        delay: 500,
        data: (params) ->
          return {
            q: params.term
          }
        ,
        processResults: (data, params) ->
          return { results: data }
        cache: true

setupSelect2ForStartup = ->
  userInput = $('#vocalist_ping_startups')

  if userInput.length > 0
    userInput.select2
      width: '300px',
      placeholder: 'Search by Product Name',
      minimumInputLength: 3,
      ajax:
        url: '/admin/startups/search_startup',
        dataType: 'json',
        delay: 500,
        data: (params) ->
          return {
            q: params.term
          }
        ,
        processResults: (data, params) ->
          return { results: data }
        cache: true

clearSelection = (element) ->
  element.val(null).trigger('change')

$(document).on 'turbolinks:load', ->
  if $('#new_vocalist_ping').length
    initializeSelect2s()
    handleTargetChanges()
    setupSelect2ForStartup()
    setupSelect2ForFounder()
