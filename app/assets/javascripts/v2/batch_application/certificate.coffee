this.buildApplicationCertificate = buildCertificatePDF = (certificateBackground, teamMembers, codeScore, videoScore, result) ->
  doc = new jsPDF('p', 'in', 'letter')
  doc.addImage "data:image/png;base64,#{certificateBackground}", 'png', 0, 0, 8.5, 11

  doc.setFont("helvetica")
  doc.setFontSize(14)

  for founder, index in teamMembers
    doc.text 0.8, index/3 + 5.565, "#{index + 1}. #{founder}"

  doc.text 5.9, 5.565, String(codeScore)
  doc.text 5.8, 5.965, String(videoScore)
  doc.text 4.8, 7.25, String(result)
  doc

showCertificate = ->
  if $('.certificate-preview-container').is(':visible')
    doc = buildCertificatePDF(loadCertificateData()...)
    datauri = doc.output('datauristring')
    $('#certificate-content')[0].src = datauri

loadCertificateData = ->
  certificateBackground = $('#certificate-content').data('background')
  teamMembers = $('#certificate-content').data('teamMembers')
  codeScore = $('#certificate-content').data('codeScore')
  videoScore = $('#certificate-content').data('videoScore')
  result = $('#certificate-content').data('result')

  [certificateBackground, teamMembers, codeScore, videoScore, result]

handleDownload = ->
  $('.certificate-download-button').click ->
    console.log 'Downloading Certificate'
    doc = buildCertificatePDF(loadCertificateData()...)
    doc.save('Certificate.pdf')

$(document).on 'page:change', ->
  if $('#certificate-content').length > 0
    showCertificate()
    handleDownload()
