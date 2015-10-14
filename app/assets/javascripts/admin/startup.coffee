$(document).on 'page:change', ->
    $('#startup_founder_ids').select2({ placeholder : 'Add Founder' })
    $('#startup_startup_category_ids').select2({ placeholder : 'Select Category' })
