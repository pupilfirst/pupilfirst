# TODO: Custom JS written for custom-file-input on Bootstrap 4 Alpha 3, which doesn't have a fully featured file input.
# This JS, coupled with styling, allows the name of the selected file to be displayed in the file input box.
prepareCustomFileInput = ->
  executableInput = $('#application_stage_two_executable')

  executableInput.change ->
    filename = $(this)[0].files[0].name
    customFileControl = $(this).next('.custom-file-control')
    customFileControl.attr('data-content', filename)
    customFileControl.addClass 'custom-after-content'

prepareAppTypeSwitch = ->
  $('#application_stage_two_app_type').change ->
    switchAppType()

switchAppType = ->
  inputValue = $('#application_stage_two_app_type').val()

  if inputValue == 'Website'
    hideSection('label.custom-file')
    showSection('.application_stage_two_website')
  else
    hideSection('.application_stage_two_website')
    showSection('label.custom-file')

hideSection = (finder) ->
  websiteSection = $(finder)
  websiteSection.addClass('hidden-xs-up')
  websiteSection.find('input').prop('disabled', true)

showSection = (finder) ->
  websiteSection = $(finder)
  websiteSection.removeClass('hidden-xs-up')
  websiteSection.find('input').prop('disabled', false)

$(document).on 'page:change', prepareCustomFileInput

$(document).on 'page:change', ->
  prepareAppTypeSwitch()
  switchAppType()
