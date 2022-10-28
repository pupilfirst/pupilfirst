import * as React from "react";
import * as ReactDom from "react-dom";

import { makeFromJson as StudentDistribution } from "~/courses/students/components/CoursesStudents__StudentDistribution.bs.js";
import { makeFromJson as SimpleDropdownFilter } from "~/shared/components/SimpleDropdownFilter.bs.js";

const selectComponent = (name) => {
  switch (name) {
    case "StudentDistribution":
      return StudentDistribution;
    case "SimpleDropdownFilter":
      return SimpleDropdownFilter;
    default:
      throw new Error(`Unknown component name: ${name}`);
  }
};

document.querySelectorAll("[data-re-component]").forEach(function (el) {
  const component = selectComponent(el.dataset.reComponent);
  const props = JSON.parse(el.dataset.reJson);

  ReactDom.render(React.createElement(component, props), el);
});
