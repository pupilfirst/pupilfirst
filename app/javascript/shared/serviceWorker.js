window.addEventListener('load', () => {
  navigator.serviceWorker.register('/service-worker.js').then(registration => {
    console.log('ServiceWorker registered: ', registration);



    var serviceWorker;
    if (registration.installing) {
      serviceWorker = registration.installing;
      console.log('Service worker installing.');
    } else if (registration.waiting) {
      serviceWorker = registration.waiting;
      console.log('Service worker installed & waiting.');
    } else if (registration.active) {
      serviceWorker = registration.active;
      console.log('Service worker active.');
    }

    showWebPushData()

    document.getElementById('btn-enable').addEventListener('click', async () => {
      const sw = await navigator.serviceWorker.ready
      const s = new Uint8Array(JSON.parse(document.documentElement.getAttribute("data-vapid-public-key")))
      await sw.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: s
      })
      showWebPushData()
    })


  }).catch(registrationError => {
    console.log('Service worker registration failed: ', registrationError);
  });
});


async function getWebPushData() {
  const sw = await navigator.serviceWorker.ready
  const subscription = await sw.pushManager.getSubscription()
  return subscription ? subscription.toJSON() : null
}

async function showWebPushData() {
  const data = await getWebPushData()
  if (data) {
    // document.getElementById('endpoint').innerText = data.endpoint
    // document.getElementById('p256dh').innerText = data.keys.p256dh
    // document.getElementById('auth').innerText = data.keys.auth
    console.log("endpoint", data.endpoint)
    console.log("p256dh", data.keys.p256dh)
    console.log("auth", data.keys.auth)
  }
}
