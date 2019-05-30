import * as React from "react";
import * as ReactDOM from "react-dom";
import { jsComponent } from "../../../schools/courses/components/CourseEditor.bs";

const root = document.getElementById("course-editor");
const props = JSON.parse(root.dataset.props);
ReactDOM.render(React.createElement(jsComponent, props), root);
