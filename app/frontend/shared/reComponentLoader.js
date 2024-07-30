import * as React from "react";
import * as ReactDom from "react-dom";

import { makeFromJson as Avatar } from "~/shared/Avatar.bs.js";
import { makeFromJson as SimpleDropdownFilter } from "~/shared/components/SimpleDropdownFilter.bs.js";
import { makeFromJson as CalendarsIndex__DatePicker } from "~/admin/courses/calendars_index/CalendarsIndex__DatePicker.bs.js";
import { makeFromJson as MarkdownBlock } from "~/shared/components/MarkdownBlock.bs.js";
import { makeFromJson as SimpleMarkdownEditor } from "~/shared/components/SimpleMarkdownEditor.bs.js";
import { makeFromJson as SelectLink } from "~/shared/components/SelectLink.bs.js";
import { makeFromJson as SimpleMultiSelectInline } from "~/shared/components/SimpleMultiSelectInline.bs.js";
import { makeFromJson as HelpIcon } from "~/shared/components/HelpIcon.bs.js";
import { make as SimpleBackButton } from "~/shared/components/SimpleBackButton.bs.js"

const selectComponent = (name) => {
  switch (name) {
    case "Avatar":
      return Avatar;
    case "SimpleDropdownFilter":
      return SimpleDropdownFilter;
    case "CalendarsIndex__DatePicker":
      return CalendarsIndex__DatePicker;
    case "MarkdownBlock":
      return MarkdownBlock;
    case "SimpleMarkdownEditor":
      return SimpleMarkdownEditor;
    case "SimpleMultiSelectInline":
      return SimpleMultiSelectInline;
    case "SelectLink":
      return SelectLink;
    case "HelpIcon":
      return HelpIcon;
    case "SimpleBackButton":
      return SimpleBackButton;
    default:
      throw new Error(`Unknown component name: ${name}`);
  }
};

window.onload = function () {
  const schoolRouterInnerPageData = document.getElementById(
    "schoolrouter-innerpage-data"
  );
  if (schoolRouterInnerPageData) {
    document.getElementById("schoolrouter-innerpage").innerHTML =
      schoolRouterInnerPageData.innerHTML;
    schoolRouterInnerPageData.remove();
  }

  document.querySelectorAll("[data-re-component]").forEach(function (el) {
    const component = selectComponent(el.dataset.reComponent);
    const props = JSON.parse(el.dataset.reJson);

    ReactDom.render(React.createElement(component, props), el);
  });
};
