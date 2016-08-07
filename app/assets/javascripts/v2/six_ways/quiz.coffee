showFirstQuestion = ->
  $('#question-container-0').removeClass('hidden-xs-up')

handleAnswerSubmission = ->
  $('.answer-submit-button').click(->
    questionIndex = $(this).data().questionIndex
    clearPreviousResults()
    analyzeSubmission(questionIndex)
  )

handleQuestionSkip = ->
  $('.question-skip-button').click(->
    questionIndex = $(this).data().questionIndex
    showQuestion(questionIndex + 1)
    resetButtons()
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
    $('.answer-submit-button').addClass('hidden-xs-up')
    $('.question-skip-button a').html('Next')

resetButtons = ->
  $('.answer-submit-button').removeClass('hidden-xs-up')
  $('.question-skip-button a').html('Skip')

correctAnswer = (questionIndex) ->
  return $("#question-container-#{questionIndex}").data().correctAnswerId

showQuestion = (questionIndex) ->
  $('.question-container').addClass('hidden-xs-up')
  $("#question-container-#{questionIndex}").removeClass('hidden-xs-up')
  showFinishButton() if lastQuestion(questionIndex)

showFinishButton = ->
  $('.question-skip-button').addClass('hidden-xs-up')
  $('#quiz-submit-button').removeClass('hidden-xs-up')

lastQuestion = (questionIndex) ->
  return questionIndex is $('#quiz-form-data').data().questionCount - 1

clearPreviousResults = ->
  $('.no-selection-error').addClass('hidden-xs-up')
  $('.answer-result').addClass('hidden-xs-up')
  $('.answer-hint').addClass('hidden-xs-up')

$(document).on 'page:change', showFirstQuestion
$(document).on 'page:change', handleAnswerSubmission
$(document).on 'page:change', handleQuestionSkip
