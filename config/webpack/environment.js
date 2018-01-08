const { environment } = require("@rails/webpacker");
const merge = require("webpack-merge");

const myCssLoaderOptions = {
  modules: true,
  sourceMap: true,
  localIdentName: "[path]___[name]__[local]___[hash:base64:5]"
};

const CSSLoader = environment.loaders
  .get("sass")
  .use.find(el => el.loader === "css-loader");

CSSLoader.options = merge(CSSLoader.options, myCssLoaderOptions);

module.exports = environment;
