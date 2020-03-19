type props = {schoolId: string};

let decodeProps = json =>
  Json.Decode.{schoolId: json |> field("schoolId", string)};

let props =
  DomUtils.parseJsonTag(~id="school-payments-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SchoolPayments__Editor schoolId={props.schoolId} />,
  "school-payments",
);
