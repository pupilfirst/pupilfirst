storeIntercomSettings = ->
  # try scraping page url for UTM params
  UTMParams = getUTMParams(location.search)

  # try scraping the referrer url too, if required
  if _.isEmpty(UTMParams) && _.includes(document.referrer, '?')
    referrerQuery = document.referrer.split('?')[1]
    UTMParams = getUTMParams(referrerQuery)

  if !_.isEmpty(UTMParams)
    console.log('Storing UTM params to intercomSettings')
    _.extend(window.intercomSettings, UTMParams)

getUTMParams = (query) ->
  _.chain(query)
    .replace('?', '') # remove the starting ?
    .split('&') # split at &s
    .map(_.ary(_.partial(_.split, _, '='), 1)) # convert to array of key-value pairs
    .fromPairs() # convert to object
    .pickBy((value, key) -> _.startsWith(key, 'utm_')) # select the UTM parameters
    .value()

$(document).on 'page:change', storeIntercomSettings
