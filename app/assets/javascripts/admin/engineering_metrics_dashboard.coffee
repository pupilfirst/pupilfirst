chartDeploys = ->
  chartData = $('#engineering-metrics-dashboard__deploys').data('chartData')
  new Chartkick.LineChart('engineering-metrics-dashboard__deploys', chartData)

chartBugs = ->
  chartData = $('#engineering-metrics-dashboard__bugs').data('chartData')
  new Chartkick.LineChart('engineering-metrics-dashboard__bugs', chartData)

chartCommits = ->
  chartData = $('#engineering-metrics-dashboard__commit-trend').data('chartData')
  new Chartkick.LineChart('engineering-metrics-dashboard__commit-trend', chartData)

chartAdditionDeletion = ->
  chartData = $('#engineering-metrics-dashboard__additions-deletions').data('chartData')
  new Chartkick.LineChart('engineering-metrics-dashboard__additions-deletions', chartData, colors: ['#228B22', '#FF0000'])

chartLanguages = ->
  chartData = $('#engineering-metrics-dashboard__loc').data('chartData')
  new Chartkick.LineChart('engineering-metrics-dashboard__loc', chartData)

$(document).on 'turbolinks:load', ->
  if $('#admin__engineering-metrics-dashboard').length
    chartDeploys()
    chartBugs()
    chartCommits()
    chartAdditionDeletion()
    chartLanguages()
