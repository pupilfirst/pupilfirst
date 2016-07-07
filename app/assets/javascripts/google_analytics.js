if(/sv\.co/.test(window.location.hostname)) {
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  console.log('Google Analytics Debug: Create');
  ga('create', 'UA-65573888-1', 'auto');
} else {
  console.log('Detected development environment. Mocking function ga()...');

  function ga() {
    var params = Array.prototype.slice.call(arguments, ga.length);
    console.log('Google Analytics Capture: ' + params);
  }
}

$(document).on('page:change', function() {
  console.log('Google Analytics Debug: Page view');
  ga('send', 'pageview', window.location.pathname);
});
