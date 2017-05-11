displayAllCharts = ->
  displayPaidApplicantsByReference()
  displayPaidApplicationsByLocation()
  displayPaidApplicationsByDate()
  displayPaidApplicationsByTeamSize()

displayPaidApplicantsByReference = ->
  chartData = $('#paid_applicants_by_reference').data('chartData')
  new (Chartkick.PieChart)('paid_applicants_by_reference', chartData)

displayPaidApplicationsByLocation = ->
  chartData = $('#paid_applications_by_location').data('chartData')
  new (Chartkick.PieChart)('paid_applications_by_location', chartData)

displayPaidApplicationsByDate = ->
  chartData = $('#paid_applications_by_date').data('chartData')
  new (Chartkick.ColumnChart)('paid_applications_by_date', chartData)

displayPaidApplicationsByTeamSize = ->
  chartData = $('#paid_applications_by_team_size').data('chartData')
  new (Chartkick.ColumnChart)('paid_applications_by_team_size', chartData)

$(document).on 'page:change', ->
  if $('.admissions-dashboard-container').length > 0
    displayAllCharts()

chartLevelZeroAge = ->
  chartData = $('#admissions-dashboard__level-zero-age').data('chartData')
  new Chartkick.ColumnChart('admissions-dashboard__level-zero-age', chartData)

$(document).on 'turbolinks:load', ->
  if $('#admin__admissions-dashboard').length
    chartLevelZeroAge()
