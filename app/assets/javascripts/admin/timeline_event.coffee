betterFormControls = ->
  $('#timeline_event_startup_id').select2(width: '400px')

loadFoundersForStartup = ->
  $('#timeline_event_startup_id').change (e) ->
    selectedStartupId = $(e.target).find(':selected').val()
    foundersForStartupUrl = $('#timeline-event-founders-for-startup-url').data('url')

    $.get(foundersForStartupUrl, { startup_id: selectedStartupId }).success (data) ->
      $('#timeline_event_founder_id').html(data.founder_options)

setupTargetSelect2 = ->
  targetSelect = $('.js-admin-timeline-events__link-target-select')

  if targetSelect.length
    targetSelect.select2
      width: '50%'
      minimumInputLength: 3,
      ajax:
        url: '/targets/select2_search',
        dataType: 'json',
        delay: 500,
        data: (params) ->
          return {
            q: params.term
          }
        ,
        processResults: (data, params) ->
          return { results: data }
        cache: true

destroySelect2Inputs = ->
  $('.js-admin-timeline-events__link-target-select').select2('destroy');

$(document).on 'page:change', betterFormControls
$(document).on 'page:change', loadFoundersForStartup

$(document).on 'turbolinks:load', ->
  if $('.admin-timeline_events__show').length
    setupTargetSelect2()

$(document).on 'turbolinks:before-cache', ->
  if $('.admin-timeline_events__show').length
    destroySelect2Inputs()
