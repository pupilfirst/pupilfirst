open Webapi.Dom;

// let isDevelopment = () =>
//   switch (
//     document |> Document.documentElement |> Element.getAttribute("data-env")
//   ) {
//   | Some(props) when props == "development" => true
//   | Some(_)
//   | None => false
//   };

// let c =
document
|> Document.documentElement
|> Element.getAttribute("data-vapid-public-key");

// Window.addEventListener("load", e => (), window) /* })*/;

// Window.navigator.serviceWorker.register()

// window.addEventListener('load', () => {
//   navigator.serviceWorker.register('/service-worker.js').then(registration => {
//     console.log('ServiceWorker registered: ', registration);

//     var serviceWorker;
//     if (registration.installing) {
//       serviceWorker = registration.installing;
//       console.log('Service worker installing.');
//     } else if (registration.waiting) {
//       serviceWorker = registration.waiting;
//       console.log('Service worker installed & waiting.');
//     } else if (registration.active) {
//       serviceWorker = registration.active;
//       console.log('Service worker active.');
//     }

//   }).catch(registrationError => {
//     console.log('Service worker registration failed: ', registrationError);
//   });
