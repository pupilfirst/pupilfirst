sendUserDataToInspectlet = ->
  inspectletData = $('#inspectlet-data')
  emailAddress = inspectletData.data 'userEmail'

  if __insp? and emailAddress
    productName = inspectletData.data 'productName'

    if emailAddress
      __insp.push ['identify', emailAddress]

    if productName
      __insp.push ['tagSession', {email: emailAddress, productName: productName}]

$(sendUserDataToInspectlet)
