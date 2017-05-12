chartAdditionDeletion = ->
  chartData = $('#engineering-metrics-dashboard__additions-deletions').data('chartData')
  new Chartkick.LineChart('engineering-metrics-dashboard__additions-deletions', chartData, colors: ['#228B22', '#FF0000'])

chartDataByType = (type) ->
  chartData = $("#engineering-metrics-dashboard__#{type}").data('chartData')
  new Chartkick.LineChart("engineering-metrics-dashboard__#{type}", chartData)

$(document).on 'turbolinks:load', ->
  if $('#admin__engineering-metrics-dashboard').length
    chartAdditionDeletion()
    chartDataByType('deploys')
    chartDataByType('bugs')
    chartDataByType('commit-trend')
    chartDataByType('loc')
    chartDataByType('coverage')
