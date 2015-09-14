handleLinkEditing = ->
  $('a.edit-existing-link').click (event) ->
    link = $(event.target)
    form = $('#edit-existing-link-form')
    form.slideDown()
    form.find('input[name=link_index]').val(link.data('index'))
    form.find('input[name=link_title]').val(link.data('title'))
    form.find('input[name=link_url]').val(link.data('url'))

  $('a#cancel-edit').click ->
    $('#edit-existing-link-form').slideUp()

$(handleLinkEditing)
