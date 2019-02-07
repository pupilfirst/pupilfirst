select2ForConnectSlot = ->
  $('#connect_request_connect_slot').select2(width: '100%')

newConnectRequestFormHandler = ->
  $('form.new_connect_request').submit (event) ->
    form = $(event.target)

    questions = form.find('#connect_request_questions')

    unless questions.val().length
      questions.attr('placeholder', 'You must supply at least one question.')
      questions.closest('.form-group').addClass('has-error')
      event.preventDefault()

destroySelect2Inputs = ->
  connectSlotInput = $('#connect_request_connect_slot')

  if connectSlotInput.length
    connectSlotInput.select2('destroy')
    connectSlotInput.val('')

$(document).on 'turbolinks:load', ->
  if $('#faculty__index').length
    newConnectRequestFormHandler()

  if $('#faculty__index').length || $('#faculty__show').length
    select2ForConnectSlot()

$(document).on 'turbolinks:before-cache', ->
  if $('#faculty__index').length || $('#faculty__show').length
    destroySelect2Inputs()
