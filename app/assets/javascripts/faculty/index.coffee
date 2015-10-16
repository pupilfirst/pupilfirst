select2ForConnectSlot = ->
  $('#connect_request_connect_slot').select2()

newConnectRequestFormHandler = ->
  $('form.new_connect_request').submit (event) ->
    form = $(event.target)

    questions = form.find('#connect_request_questions')

    unless questions.val().length
      questions.attr('placeholder', 'You must supply at least one question.')
      questions.closest('.form-group').addClass('has-error')
      event.preventDefault()

$(document).on 'page:change', select2ForConnectSlot
$(document).on 'page:change', newConnectRequestFormHandler
