buildCertificatePDF = ->
  if $('#certificate-content')
    console.log 'Building Certificate'
    doc = new jsPDF('p', 'pt', 'letter')
    doc.addImage "data:image/jpg;base64,#{$('#certificate-content').data('background')}", 'jpg', 0, 0
    doc.text 10, 70, 'This text was build by jsPDF'
    datauri = doc.output('datauristring')
    showCertificate datauri
    doc.save 'JSCertificate.pdf'

showCertificate = (datauri) ->
  $('#certificate-content')[0].src = datauri

handleDownload = ->
  $('#download-button').click ->
    console.log 'Downloading Certificate'

#$(document).on 'page:change', buildCertificatePDF
#$(document).on 'page:change', handleDownload
