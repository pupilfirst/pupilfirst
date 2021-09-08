const { environment } = require("@rails/webpacker");
const webpack = require("webpack");
const dotenv = require("dotenv");

const dotenvFiles = [
  `.env.${process.env.NODE_ENV}.local`,
  ".env.local",
  `.env.${process.env.NODE_ENV}`,
  ".env",
];

dotenvFiles.forEach((dotenvFile) => {
  dotenv.config({ path: dotenvFile, silent: true });
});

environment.plugins.prepend(
  "Environment",
  new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(process.env)))
);

// Workaround for webpacker + postcss-loader v4 incompatibility.
// Source: https://github.com/rails/webpacker/issues/2784
const hotfixPostcssLoaderConfig = (subloader) => {
  const subloaderName = subloader.loader;

  if (subloaderName === "postcss-loader") {
    if (subloader.options.postcssOptions) {
      console.log(
        "\x1b[31m%s\x1b[0m",
        "Remove postcssOptions workaround in config/webpack/environment.js"
      );
    } else {
      subloader.options.postcssOptions = subloader.options.config;
      delete subloader.options.config;
    }
  }
};

environment.loaders.keys().forEach((loaderName) => {
  const loader = environment.loaders.get(loaderName);
  loader.use.forEach(hotfixPostcssLoaderConfig);
});

module.exports = environment;
