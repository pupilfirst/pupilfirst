showFirstQuestion = ->
  $('#question-container-0').removeClass('hidden-xs-up')

handleAnswerSelect = ->
  $('.question-container:not(.hidden-xs-up) input.radio_buttons').click(->
    $('.question-next-button').removeClass('hidden-xs-up')
  )

handleAnswerSubmission = ->
  $('.answer-check-button').click(->
    questionIndex = $(this).data().questionIndex
    clearPreviousResults()
    analyzeSubmission(questionIndex)
  )

handleQuestionSkip = ->
  $('.question-skip-button').click(->
    questionIndex = $(this).data().questionIndex
    clearSelectedAnswer(questionIndex)
    if lastQuestion(questionIndex) then submitForm() else showQuestion(questionIndex + 1)
  )

handleQuestionNext = ->
  $('.question-next-button').click(->
    questionIndex = $(this).data().questionIndex
    showQuestion(questionIndex + 1)
  )

analyzeSubmission = (questionIndex) ->
  submittedAnswerId = $("input[name='quiz_submission[questions_attributes][#{questionIndex}][answer_id]']:checked").val()
  if submittedAnswerId? then showResult(submittedAnswerId) else showNoSelectionError(questionIndex)
  modifyButtons(questionIndex, submittedAnswerId)

showResult = (submittedAnswerId) ->
  $("#answer-#{submittedAnswerId}-result").removeClass('hidden-xs-up')
  $("#answer-#{submittedAnswerId}-hint").removeClass('hidden-xs-up')

showNoSelectionError = (questionIndex) ->
  $("#no-selection-error-#{questionIndex}").removeClass('hidden-xs-up')

modifyButtons = (questionIndex, submittedAnswerId) ->
  if parseInt(submittedAnswerId) is correctAnswer(questionIndex)
    $('.answer-check-button').addClass('hidden-xs-up')
    # Disable input if the answer is correct
    # $('input[name="quiz_submission[questions_attributes]['+questionIndex+'][answer_id]"]').prop('readonly',true)
    $('.question-skip-button').addClass('hidden-xs-up')


resetButtons = ->
  $('.answer-check-button').removeClass('hidden-xs-up')
  $('.question-skip-button').removeClass('hidden-xs-up')
  $('.question-next-button').addClass('hidden-xs-up')

correctAnswer = (questionIndex) ->
  return $("#question-container-#{questionIndex}").data().correctAnswerId

showQuestion = (questionIndex) ->
  $('.question-container').addClass('hidden-xs-up')
  $("#question-container-#{questionIndex}").removeClass('hidden-xs-up')
  resetButtons()
  showFinishButton() if lastQuestion(questionIndex)
  handleAnswerSelect()

showFinishButton = ->
  $('.question-next-button').addClass('hidden-xs-up')
  $('#quiz-submit-button').removeClass('hidden-xs-up')

lastQuestion = (questionIndex) ->
  return questionIndex is $('#quiz-form-data').data().questionCount - 1

clearPreviousResults = ->
  $('.no-selection-error').addClass('hidden-xs-up')
  $('.answer-result').addClass('hidden-xs-up')
  $('.answer-hint').addClass('hidden-xs-up')

clearSelectedAnswer = (questionIndex) ->
  $('input[name="quiz_submission[questions_attributes]['+questionIndex+'][answer_id]"]').prop('checked',false)

submitForm = ->
  $('#new_quiz_submission').submit()

$(document).on 'page:change', showFirstQuestion
$(document).on 'page:change', handleAnswerSelect
$(document).on 'page:change', handleAnswerSubmission
$(document).on 'page:change', handleQuestionSkip
$(document).on 'page:change', handleQuestionNext
