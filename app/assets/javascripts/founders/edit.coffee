setupSelect2Inputs = ->
  $('#founder_roles').select2(
    placeholder: 'Select roles at startup'
  )

  collegeInput = $('#founder_college_id')

  if collegeInput.length
    collegeSearchUrl = collegeInput.data('searchUrl')

    collegeInput.select2
      minimumInputLength: 3,
      ajax:
        url: collegeSearchUrl,
        dataType: 'json',
        quietMillis: 500,
        data: (term, page) ->
          return {
            q: term
          }
        ,
        results: (data, page) ->
          return { results: data }
        cache: true

toggleUniversityFields = ->
  fieldsToToggle = [$('.founder_roll_number'),$('.founder_college_identification'), $('.founder_course'),  $('.founder_semester'), $('.founder_year_of_graduation')]
  if $("#founder_university_id").val()
    for field in fieldsToToggle
      field.show()
  else
    for field in fieldsToToggle
      field.hide()

$(document).on 'page:change', ->
  toggleUniversityFields()
  $("#founder_university_id").change toggleUniversityFields

$(document).on 'turbolinks:load', ->
  if $('#founder_college_id').length
    setupSelect2Inputs()
