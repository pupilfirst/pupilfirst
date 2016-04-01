activateMapsOnClick = ->
  $('.google-maps-iframe-container').click ->
    $('.google-maps-iframe-container iframe').css('pointer-events', 'auto')

  $('.google-maps-iframe-container').mouseleave ->
    $('.google-maps-iframe-container iframe').css('pointer-events', 'none')

displayContactAlerts = ->
  if $("#contact_form_query_type").val() == "Space Availability Question"
    $("#contact-alerts").html('<p><strong>Note:</strong> SV.CO no longer provides office-space for startups. If you are looking for space in Kochi, we recommend you contact KSUM. If you are in Vizag, please reach out to Innovation Society.</p><p>To contact KSUM, please reach out to Sreerag (<a href="mailto:sreerag@startupmission.in">sreerag@startupmission.in</a>).</p>')
    $("#contact-alerts").show()
  else if $("#contact_form_query_type").val() == "Incubation Help"
    $("#contact-alerts").html('<p><strong>Note:</strong> Our admission process is in two batches per year. Because of the volume of requests we receive, we will not be able to help founders outside our well-defined 6-month program. For more details on our program please go through our <a href="http://playbook.sv.co/">Playbook</a>. If you meet the eligibility criteria please keep a tab on our blog and our website to get to know when the applications for the next batch open.</p><p>Also please note that our batches are focussed on one particular domain (e.g. Batch 1: FinTech, Batch 2: SaaS) and we will not be providing case by case assistance to startups.</p>')
    $("#contact-alerts").show()
  else
    $("#contact-alerts").hide()


$(document).on 'page:change', activateMapsOnClick
$(document).on 'page:change', ->
  displayContactAlerts()
  $("#contact_form_query_type").change displayContactAlerts


