setupSelect2ForTaggings = ->
  $('#q_taggable_id').select2(width: '100%')
  $('#q_tag_id').select2(width: '100%')

  # Filters on index pages.
  $('#q_ransack_tagged_with').select2(width: '100%');

destroySelect2ForTaggings = ->
  $('#q_taggable_id').select2('destroy')
  $('#q_tag_id').select2('destroy')
  $('#q_ransack_tagged_with').select2('destroy')

$(document).on 'turbolinks:load', setupSelect2ForTaggings
$(document).on 'turbolinks:before-cache', destroySelect2ForTaggings
