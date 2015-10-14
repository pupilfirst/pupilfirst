limitLength = (element, length) ->
  if element.value.length > length
    element.value = element.value.slice(0, length)

$(document).on 'page:change', ->
  $('input[data-max-int-length]').on 'input', ->
    maxIntLength = parseInt(this.getAttribute("data-max-int-length"))
    limitLength(this, maxIntLength)
