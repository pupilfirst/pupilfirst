var manifestJSON = {
  "short_name": "LMS",
  "name": "Pupilfirst LMS",
  "icons": [
    {
     "src": "\/favicon.ico",
     "sizes": "36x36",
     "type": "image\/png",
     "density": "0.75"
    },
   ],
  "start_url": "/",
  "background_color": "#3367D6",
  "display": "standalone",
  "scope": "/",
  "theme_color": "#3367D6",
}

const stringManifest = JSON.stringify(manifestJSON);
const blob = new Blob([stringManifest], {type: 'application/json'});
const manifestURL = URL.createObjectURL(blob);
document.querySelector('#app-manifest').setAttribute('href', manifestURL);
