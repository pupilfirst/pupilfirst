function subscriptionDetails(data) {
  return { endpoint: data.endpoint, p256dh: data.keys.p256dh, auth: data.keys.auth }
};

export async function getWebPushData() {
  const sw = await navigator.serviceWorker.ready
  const subscription = await sw.pushManager.getSubscription()
  return subscription === null ? null : subscriptionDetails(subscription.toJSON())
}

export async function createSubscription() {
  const sw = await navigator.serviceWorker.ready
  const vapidPublicKey = JSON.parse(document.documentElement.getAttribute("data-vapid-public-key"))
  if (vapidPublicKey) {
    await sw.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: new Uint8Array(vapidPublicKey)
    })
  }

  return getWebPushData()
}
