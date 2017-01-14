prepareAppTypeSwitch = ->
  $('#batch_applications_coding_stage_app_type').change ->
    switchAppType()

switchAppType = ->
  inputValue = $('#batch_applications_coding_stage_app_type').val()

  if inputValue == 'Website'
    hideSection('.batch_applications_coding_stage_executable')
    showSection('.batch_applications_coding_stage_website')
  else
    hideSection('.batch_applications_coding_stage_website')
    showSection('.batch_applications_coding_stage_executable')

hideSection = (finder) ->
  websiteSection = $(finder)
  websiteSection.addClass('hidden-xs-up')
  websiteSection.find('input').prop('disabled', true)

showSection = (finder) ->
  websiteSection = $(finder)
  websiteSection.removeClass('hidden-xs-up')
  websiteSection.find('input').prop('disabled', false)

$(document).on 'turbolinks:load', ->
  if $('#batch-application__stage-3').length
    prepareAppTypeSwitch()
    switchAppType()
