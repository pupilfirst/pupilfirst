setupSelect2ForTaggings = ->
  $('#q_taggable_id').select2(width: '100%')
  $('#q_tag_id').select2(width: '100%')

$(document).on 'page:change', setupSelect2ForTaggings
