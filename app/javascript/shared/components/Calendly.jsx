import React from 'react';
import { InlineWidget, PopupText } from "react-calendly";

export function popupText(props) {
  return (
    <PopupText
      url={props.url}
      text={props.text}
      styles={props.styles}
      prefill={props.prefill}
      pageSettings={props.pageSettings}
      utm={props.utm}
      id={props.id}
    />
  );
};

export default function Calendly(props) {
  return (
    <InlineWidget
      url={props.url}
      styles={props.styles}
      prefill={props.prefill}
      pageSettings={props.pageSettings}
      utm={props.utm}
      id={props.id}
    />
  );
};
