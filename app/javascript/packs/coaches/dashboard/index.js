import * as React from "react";
import * as ReactDOM from "react-dom";
import { make, jsComponent } from "../../../coaches/index.bs";

$(document).on("turbolinks:load", () => {
  const root = document.getElementById("coaches-dashboard");
  // const props = $(root).data("props");
  const props = { name: "Hari", age: "30" };
  // ReactDOM.render(element(undefined, undefined, make('Mahesh', '30')), root);
  ReactDOM.render(React.createElement(jsComponent, props), root);
});
