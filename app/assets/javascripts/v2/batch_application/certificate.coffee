buildCertificatePDF = ->
  console.log 'Building Certificate'
  doc = new jsPDF('p', 'in', 'letter')
  doc.addImage "data:image/png;base64,#{$('#certificate-content').data('background')}", 'png', 0, 0, 8.5, 11
  teamMembers = $('#certificate-content').data('teamMembers')
  doc.setFont("helvetica")
  doc.setFontSize(14)
  for founder, index in teamMembers
    doc.text 0.8, index/3 + 5.565, "#{index + 1}. #{founder}"
  doc.text 5.9, 5.565, String($('#certificate-content').data('codeScore'))
  doc.text 5.8, 5.965, String($('#certificate-content').data('videoScore'))
  doc.text 4.8, 7.25, String($('#certificate-content').data('result'))
  doc

showCertificate = ->
  if $('#certificate-content').length > 0
    doc = buildCertificatePDF()
    datauri = doc.output('datauristring')
    $('#certificate-content')[0].src = datauri

handleDownload = ->
  if $('#certificate-content').length > 0
    $('.certificate-download-button').click ->
      console.log 'Downloading Certificate'
      doc = buildCertificatePDF()
      doc.save('Certificate.pdf')


$(document).on 'page:change', showCertificate
$(document).on 'page:change', handleDownload
