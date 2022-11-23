import * as React from "react";
import * as ReactDom from "react-dom";

import { makeFromJson as Avatar } from "~/shared/Avatar.bs.js";
import { makeFromJson as LevelProgressBar } from "~/shared/components/LevelProgressBar.bs.js";
import { makeFromJson as SimpleDropdownFilter } from "~/shared/components/SimpleDropdownFilter.bs.js";
import { makeFromJson as StudentDistribution } from "~/courses/students/components/CoursesStudents__StudentDistribution.bs.js";

const selectComponent = (name) => {
  switch (name) {
    case "Avatar":
      return Avatar;
    case "LevelProgressBar":
      return LevelProgressBar;
    case "SimpleDropdownFilter":
      return SimpleDropdownFilter;
    case "StudentDistribution":
      return StudentDistribution;
    default:
      throw new Error(`Unknown component name: ${name}`);
  }
};

document.querySelectorAll("[data-re-component]").forEach(function (el) {
  const component = selectComponent(el.dataset.reComponent);
  const props = JSON.parse(el.dataset.reJson);

  ReactDom.render(React.createElement(component, props), el);
});
