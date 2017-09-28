storeIntercomSettings = ->
  # try scraping page url for utm params
  utmParams = getUtmParams(location.search)

  # try scraping the referrer url too, if required
  if _.isEmpty(utmParams) && _.includes(document.referrer, '?')
    referrerQuery = document.referrer.split('?')[1]
    utmParams = getUtmParams(referrerQuery)

  if !_.isEmpty(utmParams)
    _.extend(window.intercomSettings, utmParams)

  # also append the value in document.referrer if available
  if !_.isEmpty(document.referrer)
    _.extend(window.intercomSettings, {referrer_url: document.referrer})

getUtmParams = (query) ->
  _.chain(query)
    .replace('?', '') # remove the starting ?
    .split('&') # split at &s
    .map((e) -> _.split(e, '=')) # convert to array of key-value pairs
    .fromPairs() # convert to object
    .pickBy((value, key) -> _.startsWith(key, 'utm_')) # select the utm parameters
    .value()

$(document).ready ->
  storeIntercomSettings()
