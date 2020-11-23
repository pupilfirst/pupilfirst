export async function createSubscription() {
  const sw = await navigator.serviceWorker.ready
  console.log("create subscription")
  await sw.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: new Uint8Array(JSON.parse(document.documentElement.getAttribute("data-vapid-public-key")))
  })
  const subscription = await sw.pushManager.getSubscription()
  const data = subscription ? subscription.toJSON() : null
  console.log(data.endpoint)
  return data ? {endpoint: data.endpoint, p256dh: data.keys.p256dh, auth: data.keys.auth} : null
}

export async function getWebPushData() {
  const sw = await navigator.serviceWorker.ready
  const subscription = await sw.pushManager.getSubscription()
  return subscription ? subscription.toJSON() : null
}

export async function showWebPushData() {
  console.log("here")
  const data = await getWebPushData()
  console.log(data)
  if (data) {
    console.log("endpoint", data.endpoint)
    console.log("p256dh", data.keys.p256dh)
    console.log("auth", data.keys.auth)
  }
}

// module.exports.showWebPushData = showWebPushData;
// module.exports.getWebPushData = getWebPushData;
// module.exports.createSubscription = createSubscription;
