import * as React from "react";
import * as ReactDOM from "react-dom";
import { make, jsComponent } from "../../../coaches/dashboard/CoachDashboard.bs";

$(document).on("turbolinks:load", () => {
  const root = document.getElementById("coaches-dashboard");
  const props = $(root).data("props");
  ReactDOM.render(React.createElement(jsComponent, props), root);
});
