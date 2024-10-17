import * as React from "react";
import * as ReactDom from "react-dom";

import { make as Avatar } from "~/shared/Avatar.res.mjs";
import { makeFromJson as SimpleDropdownFilter } from "~/shared/components/SimpleDropdownFilter.res.mjs";
import { makeFromJson as CalendarsIndex__DatePicker } from "~/admin/courses/calendars_index/CalendarsIndex__DatePicker.res.mjs";
import { makeFromJson as MarkdownBlock } from "~/shared/components/MarkdownBlock.res.mjs";
import { makeFromJson as SimpleMarkdownEditor } from "~/shared/components/SimpleMarkdownEditor.res.mjs";
import { makeFromJson as SelectLink } from "~/shared/components/SelectLink.res.mjs";
import { makeFromJson as SimpleMultiSelectInline } from "~/shared/components/SimpleMultiSelectInline.res.mjs";
import { makeFromJson as HelpIcon } from "~/shared/components/HelpIcon.res.mjs";
import { make as SimpleBackButton } from "~/shared/components/SimpleBackButton.res.mjs";

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
    "schoolrouter-innerpage-data",
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
