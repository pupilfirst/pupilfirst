$(document).on 'page:change', ->
  $('#founder_startup_id').select2(width: '400px')

setupSelect2ForFounderTagList = ->
  founderTagList = $('#founder_tag_list')

  if founderTagList.length
    currentFounderTags = founderTagList.data('founderTags')
    select2Data = $.map currentFounderTags, (tag) ->
      {
        id: tag,
        text: tag
      }

    founderTagList.select2(
      width: '80%',
      placeholder: 'Select some tags',
      tags: true,
      data: select2Data,
      createSearchChoice: (term, data) ->
        filteredData = $(data).filter ->
          this.text.localeCompare(term) == 0

        if filteredData.length == 0
          return {id: term, text: term}
    )

showTargetsOptionally = ->
  $('.admin-founder-targets-show-link').click (event) ->
    showLink = $(event.target)
    founderId = showLink.data('founderId')
    $(".admin-founder-#{founderId}-hidden-target").removeClass('hide')
    showLink.hide()


setupSelect2ForFounderColleges = ->
  collegeInput = $('#founder_college_id')

  if collegeInput.length
    collegeSearchUrl = collegeInput.data('searchUrl')

    collegeInput.select2
      width: '80%',
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

$(document).on 'page:change', showTargetsOptionally
$(document).on 'page:change', setupSelect2ForFounderTagList

$(document).on 'turbolinks:load', ->
  if $('.formtastic.founder').length
    setupSelect2ForFounderColleges()
