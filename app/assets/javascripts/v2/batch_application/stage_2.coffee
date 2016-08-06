# TODO: Custom JS written for custom-file-input on Bootstrap 4 Alpha 3, which doesn't have a fully featured file input.
# This JS, coupled with styling, allows the name of the selected file to be displayed in the file input box.
prepareCustomFileInput = ->
  executableInput = $('#application_stage_two_executable')

  if executableInput.length
    executableInput.change ->
      filename = $(this)[0].files[0].name
      customFileControl = $(this).next('.custom-file-control')
      customFileControl.attr('data-content', filename)
      customFileControl.addClass 'custom-after-content'

$(document).on 'page:change', prepareCustomFileInput
