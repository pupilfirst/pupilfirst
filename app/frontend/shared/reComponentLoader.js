import * as React from "react";
import * as ReactDom from "react-dom";

import { make as StudentDistribution } from "~/courses/students/components/CoursesStudents__StudentDistribution.bs.js";

document.querySelectorAll("[data-re-component]").forEach(function (el) {
  const componentName = el.dataset.reComponent;
  const componentJson = JSON.parse(el.dataset.reJson);
  switch (componentName) {
    case "StudentDistribution":
      ReactDom.render(
        React.createElement(StudentDistribution, componentJson),
        el
      );
  }
});
