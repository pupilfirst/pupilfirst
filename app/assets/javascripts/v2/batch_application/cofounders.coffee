#toggleCollegeTextField = (index) ->
#  formName = "batch_applications_cofounders_cofounders_attributes_#{index}"
#
#  if formName != null
#    collegeTextInput = $("##{formName}_college_text")
#    collegeTextInput.prop('disabled', false)
#    collegeTextInput.parent().parent().removeClass('hidden-xs-up')
#    $("##{formName}_college_id").parent().addClass('hidden-xs-up')
#    collegeTextInput.focus()
#
#setupTogglingCollegeField = ->
#  formName = "batch_applications_cofounders_cofounders_attributes_#{index}"
#
#  if $("##{formName}_college_id").length
#    toggleCollegeTextField(index)
#    $('#batch_applications_registration_college_id').change toggleCollegeTextField
#
#setupSelect2Inputs = ->
#  $.each $('.apply-cofounders-form select'), (_index, selectElement) ->
#    setupSelect2Input(parseInt(selectElement.id[52]))
#
#setupSelect2Input = (index) ->
#  collegeSearchUrl = $('#batch-application__cofounders-form').data('collegeSearchUrl')
#
#  $("#batch_applications_cofounders_cofounders_attributes_#{index}_college_id").select2
#    minimumInputLength: 3,
#    placeholder: 'Please pick your college',
#    ajax:
#      url: collegeSearchUrl,
#      dataType: 'json',
#      delay: 500,
#      data: (params) ->
#        return {
#          q: params.term
#        }
#      ,
#      processResults: (data, params) ->
#        return { results: data }
#      cache: true
#
#destroySelect2Inputs = ->
#  $.each $('.apply-cofounders-form select'), (_index, selectElement) ->
#    destroySelect2Input(parseInt(selectElement.id[52]))
#
#destroySelect2Input = (index) ->
#  selectElement = $("#batch_applications_cofounders_cofounders_attributes_#{index}_college_id")
#  selectElement.select2('destroy')
#  selectElement.val('')
#
#setupAddCofounderButton = ->
#  $('.js-hook.cofounders-form__add-cofounder-button').click ->
#    clonedCofounder = $('.cofounder:first').clone()
#    clonedCofounder.appendTo('.cofounders-list')
#
#    # Remove elements not required for new cofounders.
#    clonedCofounder.find('.batch_applications_cofounders_cofounders_delete').remove()
#    clonedCofounder.find('.batch_applications_cofounders_cofounders_id').remove()
#
#    # Enable all inputs.
#    clonedCofounder.find('input').prop('disabled', false).val('')
#
#    # Add the delete button if its absent.
#    if clonedCofounder.find('.cofounder-delete-button').length
#      # Unhide it if present.
#      clonedCofounder.find('.cofounder-delete-button').removeClass('hidden-xs-up')
#    else
#      clonedCofounder.prepend("<div class='cofounder-delete-button'><i class='fa fa-times-circle'></i></div>")
#
#    # Make delete button work.
#    clonedCofounder.find('.cofounder-delete-button').click handleDeleteCofounderSection
#
#    # Make college select work.
#    console.log 'here'
#    console.log(clonedCofounder.find('select'))
#    clonedCofounder.find('select').select2('destroy')
#    console.log 'and done'
##    batch_applications_cofounders_cofounders_attributes_0_college_id
#
#    reindexCofounderInputs()
#
#removeDeleteButtonFromFirstCofounderSectionIfRequired = ->
#  if $('.cofounder').length == 1
#    $('.cofounder:first').find('.cofounder-delete-button').addClass('hidden-xs-up')
#  else
#    $('.cofounder:first').find('.cofounder-delete-button').removeClass('hidden-xs-up')
#
#removeAddCofounderButtonIfRequired = ->
#  if $('.cofounder').length == 5
#    $('.add-another-cofounder').addClass('hidden-xs-up')
#  else
#    $('.add-another-cofounder').removeClass('hidden-xs-up')
#
#reindexCofounderInputs = ->
#  removeDeleteButtonFromFirstCofounderSectionIfRequired()
#  removeAddCofounderButtonIfRequired()
#
#  $.each $('.cofounder'), (cofounderIndex, cofounderSection) ->
#    cofounderSection = $(cofounderSection)
#
#    $.each cofounderSection.find('label'), (index, label) ->
#      $(label).prop('for', $(label).prop('for').replace(/attributes_\d/g, "attributes_#{cofounderIndex}"))
#
#    $.each cofounderSection.find('input'), (index, input) ->
#      $(input).prop('name', $(input).prop('name').replace(/attributes]\[\d/g, "attributes][#{cofounderIndex}"))
#      $(input).prop('id', $(input).prop('id').replace(/attributes_\d/g, "attributes_#{cofounderIndex}"))
#
#setupDeleteCofounderButton = ->
#  $('.cofounder-delete-button').click handleDeleteCofounderSection
#
#handleDeleteCofounderSection = (event) ->
#  button = $(event.target)
#  button.closest('.cofounder').remove()
#  reindexCofounderInputs()
#
#$(document).on 'turbolinks:load', ->
#  if $('#batch-application__cofounders-form').length
#    setupAddCofounderButton()
#    setupDeleteCofounderButton()
#    removeDeleteButtonFromFirstCofounderSectionIfRequired()
#    removeAddCofounderButtonIfRequired()
##    setupSelect2Inputs()
#
#$(document).on 'turbolinks:before-cache', ->
#  if $('.admission-process').length
#    destroySelect2Inputs()
