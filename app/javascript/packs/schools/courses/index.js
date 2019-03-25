import * as React from "react";
import * as ReactDOM from "react-dom";
import { jsComponent } from "../../../schools/courses/components/CourseEditor.bs";

document.addEventListener("turbolinks:load", () => {
  const root = document.getElementById("course-editor");
  const props = JSON.parse(root.dataset.props);
  ReactDOM.render(React.createElement(jsComponent, props), root);
});
