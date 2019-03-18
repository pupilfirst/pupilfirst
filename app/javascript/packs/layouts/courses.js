import * as React from "react";
import * as ReactDOM from "react-dom";
import { jsComponent } from "../../layouts/courses/components/Layouts__CoursesShow.bs";

document.addEventListener("turbolinks:load", () => {
  const root = document.getElementById("layouts-courses");
  const props = JSON.parse(root.dataset.props);
  ReactDOM.render(React.createElement(jsComponent, props), root);
});
