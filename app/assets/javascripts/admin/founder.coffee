$(document).on 'page:change', ->
  $('#founder_startup_id').select2(width: '400px')

setupSelect2ForFounderTagList = ->
  founderTagList = $('#founder_tag_list')

  if founderTagList.length
    founderTagList.select2
      width: '80%',
      placeholder: 'Select some tags',
      tags: true

destroySelect2ForFounderTagList = ->
  $('#founder_tag_list').select2('destroy')

showTargetsOptionally = ->
  $('.admin-founder-targets-show-link').click (event) ->
    showLink = $(event.target)
    founderId = showLink.data('founderId')
    $(".admin-founder-#{founderId}-hidden-target").removeClass('hide')
    showLink.hide()

$(document).on 'page:change', showTargetsOptionally
$(document).on 'turbolinks:load', setupSelect2ForFounderTagList
$(document).on 'turbolinks:before-cache', destroySelect2ForFounderTagList
