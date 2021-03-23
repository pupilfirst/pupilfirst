import React from 'react';
import { InlineWidget, openPopupWidget } from "react-calendly";

//import "./Calendly.css";

export function popup({ url, prefill, pageSettings, utm }) {
  openPopupWidget({ url, prefill, pageSettings, utm })
}

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
