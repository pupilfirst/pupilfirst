import * as React from "react";
import * as ReactDOM from "react-dom";
import FeeInterface from "../../founders/fee/Interface";

$(document).on("turbolinks:load", () => {
  const root = document.getElementById("founders-fee-interface__root");
  const props = $(root).data("props");
  ReactDOM.render(React.createElement(FeeInterface, props), root);
});
