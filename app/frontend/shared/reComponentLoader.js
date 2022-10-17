import * as React from "react";
import * as ReactDom from "react-dom";

import { make as StudentDistribution } from "~/courses/students/components/CoursesStudents__StudentDistribution.bs.js";

let d = [
  {
    id: "1",
    number: 1,
    studentsInLevel: 10,
    filterName: "level",
    unlocked: true,
  },
  {
    id: "2",
    number: 2,
    studentsInLevel: 10,
    filterName: "level",
    unlocked: true,
  },
  {
    id: "3",
    number: 3,
    studentsInLevel: 30,
    filterName: "level",
    unlocked: true,
  },
];

document.querySelectorAll("[data-re-component]").forEach(function (el) {
  const componentName = el.dataset.reComponent;
  const componentJson = el.dataset.reJson;
  switch (componentName) {
    case "LevelDistribution":
      ReactDom.render(
        React.createElement(StudentDistribution, {
          studentDistribution: d,
          params: [],
        }),
        el
      );
  }
});
