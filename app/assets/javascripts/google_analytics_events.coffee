handleGAEvents = ->
  if $('#saas-article-link').length
    $('#saas-article-link').on('click', (event) ->
      console.log('SaaS Article visited!')
      ga('send', 'event', 'Link', 'click', 'SaaS-article'))

$(document).on 'page:change', handleGAEvents
