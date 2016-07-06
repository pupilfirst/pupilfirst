$(document).on 'page:change', ->
  $('#target_startup_id').select2(placeholder: 'Select a Product', width: '80%')

loadFoundersForStartup = ->
  $('#target_startup_id').change (e) ->
    # Set founders only if role is 'Founder'
    if $('#target_role').find(':selected').val() == 'founder'
      selectedStartupId = $(e.target).find(':selected').val()
      foundersForStartupUrl = $('#target-founders-for-startup-url').data('url')

      $.get(foundersForStartupUrl, { startup_id: selectedStartupId }).success (data) ->
        $('#target_founder_id').html(data.founder_options)

        # Now show the input
        $('#target_founder_id_input').show()

hideFoundersSelectOnLoad = ->
  $('#target_founder_id_input').hide()

$(document).on 'page:change', hideFoundersSelectOnLoad
$(document).on 'page:change', loadFoundersForStartup
