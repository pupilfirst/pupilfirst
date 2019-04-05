import * as React from "react";
import * as ReactDOM from "react-dom";
import { jsComponent } from "../../community/components/CommunityDashboard.bs";

document.addEventListener("turbolinks:load", () => {
  const root = document.getElementById("curriculum-editor");
  const props = JSON.parse(root.dataset.props);
  ReactDOM.render(React.createElement(jsComponent, props), root);
});
