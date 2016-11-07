buildPartnershipDeed = ->
  console.log 'Rendering Partnership Deed'
  doc = new jsPDF('p', 'in', 'letter')

  source = $('#partnership-deed-content').data().source

  doc.fromHTML source
  doc

displayDeed = ->
  if $('.partnership-deed-preview-container').is(':visible')
    doc = buildPartnershipDeed()
    datauri = doc.output('datauristring')
    $('#partnership-deed-content')[0].src = datauri

$(document).on 'page:change', ->
  if $('#partnership-deed-content').length > 0
    displayDeed()
