import * as React from "react";
import * as ReactDom from "react-dom";

import {
  make as StudentDistribution,
  decodeProps as decodeStudentDistributionProps,
} from "~/courses/students/components/CoursesStudents__StudentDistribution.bs.js";

const selectComponent = (name) => {
  switch (name) {
    case "StudentDistribution":
      return [StudentDistribution, decodeStudentDistributionProps];
    default:
      throw new Error(`Unknown component name: ${name}`);
  }
};

document.querySelectorAll("[data-re-component]").forEach(function (el) {
  const [component, decodeProps] = selectComponent(el.dataset.reComponent);
  const props = decodeProps(el.dataset.reJson);

  ReactDom.render(React.createElement(component, props), el);
});
