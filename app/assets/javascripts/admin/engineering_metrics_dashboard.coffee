chartAdditionDeletion = ->
  chartData = $('#engineering-metrics-dashboard__additions-deletions').data('chartData')
  new Chartkick.LineChart('engineering-metrics-dashboard__additions-deletions', chartData, colors: ['#228B22', '#FF0000'])

chartLanguages = ->
  chartData = $("#engineering-metrics-dashboard__loc").data('chartData')
  new Chartkick.ColumnChart("engineering-metrics-dashboard__loc", chartData)

chartDataByType = (type) ->
  chartData = $("#engineering-metrics-dashboard__#{type}").data('chartData')
  new Chartkick.LineChart("engineering-metrics-dashboard__#{type}", chartData)

$(document).on 'turbolinks:load', ->
  if $('#admin__engineering-metrics-dashboard').length
    chartAdditionDeletion()
    chartLanguages()
    chartDataByType('deploys')
    chartDataByType('bugs')
    chartDataByType('commit-trend')
    chartDataByType('language-trend')
    chartDataByType('coverage')
