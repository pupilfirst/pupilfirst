import * as React from "react";
import * as ReactDOM from "react-dom";
import { jsComponent } from "../../../schools/founders/components/StudentAdditionPanel.bs";

document.addEventListener("turbolinks:load", () => {
  const root = document.getElementById("student-addition-panel");
  const props = JSON.parse(root.dataset.props);
  ReactDOM.render(React.createElement(jsComponent, props), root);
});
