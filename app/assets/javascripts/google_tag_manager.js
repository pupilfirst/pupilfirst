// if(/sv\.co/.test(window.location.hostname)) {

// Google Tag Manager container snippet.
(function (w, d, s, l, i) {
  w[l] = w[l] || [];
  w[l].push({
    'gtm.start': new Date().getTime(), event: 'gtm.js'
  });
  var f = d.getElementsByTagName(s)[0],
    j = d.createElement(s), dl = l != 'dataLayer' ? '&l=' + l : '';
  j.async = true;
  j.src =
    'https://www.googletagmanager.com/gtm.js?id=' + i + dl;
  f.parentNode.insertBefore(j, f);
})(window, document, 'script', 'dataLayer', 'GTM-N2LS39W');

// Custom pageview event for turbolinks.
document.addEventListener('turbolinks:load', function (event) {
  let url = event.data.url;

  dataLayer.push({
    'event': 'pageView',
    'virtualUrl': url
  });
});
// }
