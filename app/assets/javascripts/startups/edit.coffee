counter = (textBox, helpBlock, maxCharacters) ->
  value = textBox.val()
  characterCount = if value then value.trim().length else 0
  helpBlock.html "#{characterCount}/#{maxCharacters} characters"

updateProductDescription = ->
  helpBlock = $(".startup_product_description p.help-block")
  textBox = $("#startup_product_description")

  # The value of max_chars should match the one in Startup::MAX_PRODUCT_DESCRIPTION_CHARACTERS
  counter(textBox, helpBlock, 150)

$ ->
  $("#startup_product_description").click(updateProductDescription).on('input', updateProductDescription)
