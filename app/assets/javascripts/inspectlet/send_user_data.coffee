sendUserDataToInspectlet = ->
  inspectletData = $('#inspectlet-data')
  emailAddress = inspectletData.data 'userEmail'

  if __insp? and emailAddress
    productName = inspectletData.data 'productName'
    startupBatch = inspectletData.data 'startupBatch'

    if emailAddress
      __insp.push ['identify', emailAddress]

    if productName || startupBatch
      __insp.push ['tagSession', {email: emailAddress, productName: productName, startupBatch: startupBatch}]

$(document).on('ready page:load', sendUserDataToInspectlet)
