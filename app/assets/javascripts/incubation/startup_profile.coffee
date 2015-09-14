counter = (textBox, helpBlock, maxCharacters) ->
  value = textBox.val()
  characterCount = if value then value.trim().length else 0
  helpBlock.html "#{characterCount}/#{maxCharacters} characters"

updateAbout = ->
  helpBlock = $(".startup_about p.help-block")
  textBox = $("#startup_about")

  # The value of max_chars should match the one in Startup::MAX_ABOUT_CHARACTERS
  counter(textBox, helpBlock, 150)

$ ->
  $("#startup_about").click(updateAbout).on('input', updateAbout)

$ ->
  $('#startup_category_ids').select2(
    placeholder : 'Select Category',
    maximumSelectionSize: 3
  )
