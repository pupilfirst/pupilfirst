displayAllCharts = ->
  if $('.admissions-dashboard-containter')
    displayPaidApplicantsByReference()
    displayPaidApplicationsByLocation()

displayPaidApplicantsByReference = ->
  chartData = $('#paid_applicants_by_reference').data('chartData')
  new (Chartkick.PieChart)('paid_applicants_by_reference', chartData)

displayPaidApplicationsByLocation = ->
  chartData = $('#paid_applications_by_location').data('chartData')
  new (Chartkick.PieChart)('paid_applications_by_location', chartData)

$(document).on 'page:change', displayAllCharts
