displayAllCharts = ->
  if $('.admissions-dashboard-containter')
    displayPaidApplicantsByReference()
    displayPaidApplicationsByLocation()
    displayPaidApplicationsByDate()

displayPaidApplicantsByReference = ->
  chartData = $('#paid_applicants_by_reference').data('chartData')
  new (Chartkick.PieChart)('paid_applicants_by_reference', chartData)

displayPaidApplicationsByLocation = ->
  chartData = $('#paid_applications_by_location').data('chartData')
  new (Chartkick.PieChart)('paid_applications_by_location', chartData)

displayPaidApplicationsByDate = ->
  chartData = $('#paid_applications_by_date').data('chartData')
  new (Chartkick.LineChart)('paid_applications_by_date', chartData)

$(document).on 'page:change', displayAllCharts
