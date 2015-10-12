handleLinkEditing = ->
  $('a.edit-existing-link').click (event) ->
    link = $(event.target)

    # Slide down the form.
    $('#edit-existing-link-form').slideDown()

    # Set index, title, URL, and private (checkbox).
    $('#link_index').val(link.data('index'))
    $('#link_title').val(link.data('title'))
    $('#link_url').val(link.data('url'))

    if link.data('private')
      $('#link_private').prop('checked', true)
    else
      $('#link_private').prop('checked', false)

  $('a#cancel-edit').click ->
    $('#edit-existing-link-form').slideUp()

betterFormControls = ->
  $('#timeline_event_startup_id').select2()
  $('#timeline_event_timeline_event_type_id').select2()

$(document).on 'page:change', handleLinkEditing
$(document).on 'page:change', betterFormControls
