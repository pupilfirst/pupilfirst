setupSelect2ForUser = ->
  $('#q_user_id').select2({placeholder: 'Any'})

  userInput = $('#q_user_id')

  if userInput.length > 0
    userInput.select2
      minimumInputLength: 3,
      ajax:
        url: '/admin/user_activities/users',
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

destroySelect2Inputs = ->
  $('#q_user_id').select2('destroy')

$(document).on 'turbolinks:load', ->
  if window.location.pathname == '/admin/user_activities'
    setupSelect2ForUser()

$(document).on 'turbolinks:before-cache', ->
  if window.location.pathname == '/admin/user_activities'
    destroySelect2Inputs()
