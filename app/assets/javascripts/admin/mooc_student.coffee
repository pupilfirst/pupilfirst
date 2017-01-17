
setupSelect2ForMoocStudentColleges = ->
  collegeInput = $('#mooc_student_college_id')

  if collegeInput.length
    collegeSearchUrl = collegeInput.data('searchUrl')

    collegeInput.select2
      width: '80%',
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

$(document).on 'page:change', setupSelect2ForMoocStudentColleges
