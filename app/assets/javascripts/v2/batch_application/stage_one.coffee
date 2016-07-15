prepareCofounderFields = ->
  cofounderRadioButtons = $('[name="application_stage_one[cofounder_count]"]')

  if cofounderRadioButtons.length
    cofounderRadioButtons.click (e) ->
      alterCofounderFields(parseInt(e.target.value))

alterCofounderFields = (count) ->
  cofounderSections = $('.cofounder-section-form')
  sectionsLength = cofounderSections.length

  return if sectionsLength.length == count

  # Delete extra sections if required.
  while sectionsLength > count
    $(cofounderSections.selector).last().remove()
    sectionsLength = $(cofounderSections.selector).length

  # Add extra sections if required.
  while sectionsLength < count
    newSection = $(cofounderSections.selector).first().clone().appendTo(cofounderSections.parent())

    # Blank copied text, if any.
    newSection.find("input[type=text], input[type=email]").removeAttr('value')

    # Set correct title.
    newSection.find('.cofounder-title').text ->
      $(this).text().replace('1', sectionsLength + 1)

    # Update labels.
    newSection.html ->
      $(this).html().replace(/attributes_0/g, "attributes_#{sectionsLength}")

    # Update inputs.
    newSection.html ->
      $(this).html().replace(/attributes]\[0/g, "attributes][#{sectionsLength}")

    sectionsLength = $(cofounderSections.selector).length

setupSelect2Inputs = ->
  $('#application_stage_one_university_id').select2()
  $('#application_stage_one_state').select2()

$(document).on 'page:change', prepareCofounderFields
$(document).on 'page:change', setupSelect2Inputs
