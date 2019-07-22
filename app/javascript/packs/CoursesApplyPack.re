[@bs.config {jsx: 3}];

type props = {authenticityToken: string};

let decodeProps = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
  };

let props =
  DomUtils.parseJsonAttribute(
    ~id="courses-apply",
    ~attribute="data-json-props",
    (),
  )
  |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <CoursesApply authenticityToken={props.authenticityToken} />,
  "courses-apply",
);
