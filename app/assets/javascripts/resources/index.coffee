$(document).on 'page:change', ->
  # TODO: v4 of Select2 will replace maximumSelectionSize with maximumSelectionLength, so specifying both for the moment.
  # Remove maximumSelectionSize after confirming upgrade to Select2 > v4.
  $('#resources-index-tags').select2({ placeholder : 'Tagged with', maximumSelectionLength: 3, maximumSelectionSize: 3 })
