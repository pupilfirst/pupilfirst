setupAddCofounderButton = ->
  $('.add-another-cofounder').click ->
    clonedCofounder = $('.cofounder:first').clone()
    clonedCofounder.appendTo('.cofounders-list')

    # Remove elements not required for new cofounders.
    clonedCofounder.find('.cofounders_cofounders_delete').remove()
    clonedCofounder.find('.cofounders_cofounders_id').remove()

    # Enable all inputs.
    clonedCofounder.find('input').prop('disabled', false).val('')

    # Add the delete button if its absent.
    if clonedCofounder.find('.cofounder-delete-button').length
      # Unhide it if present.
      clonedCofounder.find('.cofounder-delete-button').removeClass('hidden-xs-up')
    else
      clonedCofounder.prepend("<div class='cofounder-delete-button'><i class='fa fa-times-circle'></i></div>")

    clonedCofounder.find('.cofounder-delete-button').click handleDeleteCofounderSection

    reindexCofounderInputs()

removeDeleteButtonFromFirstCofounderSectionIfRequired = ->
  if $('.cofounder').length == 1
    $('.cofounder:first').find('.cofounder-delete-button').addClass('hidden-xs-up')
  else
    $('.cofounder:first').find('.cofounder-delete-button').removeClass('hidden-xs-up')

removeAddCofounderButtonIfRequired = ->
  if $('.cofounder').length == 9
    $('.add-another-cofounder').addClass('hidden-xs-up')
  else
    $('.add-another-cofounder').removeClass('hidden-xs-up')

reindexCofounderInputs = ->
  removeDeleteButtonFromFirstCofounderSectionIfRequired()
  removeAddCofounderButtonIfRequired()

  $.each $('.cofounder'), (cofounderIndex, cofounderSection) ->
    cofounderSection = $(cofounderSection)

    $.each cofounderSection.find('label'), (index, label) ->
      $(label).prop('for', $(label).prop('for').replace(/attributes_\d/g, "attributes_#{cofounderIndex}"))

    $.each cofounderSection.find('input'), (index, input) ->
      $(input).prop('name', $(input).prop('name').replace(/attributes]\[\d/g, "attributes][#{cofounderIndex}"))
      $(input).prop('id', $(input).prop('id').replace(/attributes_\d/g, "attributes_#{cofounderIndex}"))

setupDeleteCofounderButton = ->
  $('.cofounder-delete-button').click handleDeleteCofounderSection

handleDeleteCofounderSection = (event) ->
  button = $(event.target)
  button.closest('.cofounder').remove()
  reindexCofounderInputs()

$(document).on 'page:change', setupAddCofounderButton
$(document).on 'page:change', setupDeleteCofounderButton
$(document).on 'page:change', removeDeleteButtonFromFirstCofounderSectionIfRequired
$(document).on 'page:change', removeAddCofounderButtonIfRequired
