import * as React from "react";
import * as ReactDOM from "react-dom";
import Dashboard from "../../../founders/dashboard/dashboard/FounderDashboard";

$(document).on("turbolinks:load", () => {
  const root = document.getElementById("founder-dashboard__dashboard__root");
  const props = $(root).data("props");
  ReactDOM.render(React.createElement(Dashboard, props), root);
});
