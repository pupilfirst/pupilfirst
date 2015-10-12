populateSuggestedStagesOnLoad = ->
  suggestedStagesElement = $('#timeline_event_type_suggested_stage')

  if suggestedStagesElement
    suggestedStages = suggestedStagesElement.val()

    if suggestedStages
      for stage in suggestedStages.split(',')
        do (stage) ->
          $("#timeline_event_type_suggested_stages_#{stage}").attr('checked', true)

updateSuggestedStageOnCheckboxUpdate = ->
  suggestedStagesCheckboxes = $("input[name='timeline_event_type[suggested_stages][]']")

  if suggestedStagesCheckboxes
    suggestedStagesCheckboxes.on 'change', (event) ->
      eventTarget = $(event.target)
      clickedStage = eventTarget.val()
      suggestedStagesElement = $('#timeline_event_type_suggested_stage')
      suggestedStages = suggestedStagesElement.val().split ','

      if eventTarget.is(':checked')
        if clickedStage not in suggestedStages
          suggestedStages.push(clickedStage)
      else
        if clickedStage in suggestedStages
          suggestedStages = suggestedStages.filter (suggestedStage) -> suggestedStage isnt clickedStage

      suggestedStagesElement.val(suggestedStages.join ',')

$(document).on 'page:change', populateSuggestedStagesOnLoad
$(document).on 'page:change', updateSuggestedStageOnCheckboxUpdate
