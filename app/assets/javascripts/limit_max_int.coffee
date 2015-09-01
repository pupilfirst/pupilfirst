limitLength = (element, length) ->
  if element.value.length > length
    element.value = element.value.slice(0, length)

$ ->
  $('input[data-max-int-length]').on 'input', ->
    maxIntLength = parseInt(this.getAttribute("data-max-int-length"))
    limitLength(this, maxIntLength)
