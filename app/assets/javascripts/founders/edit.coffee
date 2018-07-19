setupSelect2Inputs = ->
#  $('#founders_edit_roles').select2(
#    placeholder: 'Select your role(s) in the team'
#  )

  collegeInput = $('#founders_edit_college_id')

  if collegeInput.length
    collegeSearchUrl = collegeInput.data('searchUrl')

    collegeInput.select2
      minimumInputLength: 3,
      ajax:
        url: collegeSearchUrl,
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
#  $('#founders_edit_roles').select2('destroy');
  $('#founders_edit_college_id').select2('destroy');

$(document).on 'turbolinks:load', ->
  if $('#founders_edit_college_id').length
    setupSelect2Inputs()

$(document).on 'turbolinks:before-cache', ->
  if $('#founders_edit_college_id').length > 0
    destroySelect2Inputs()
