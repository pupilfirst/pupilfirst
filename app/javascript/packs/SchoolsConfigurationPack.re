open SchoolsConfiguration__Types;

type props = {
  schoolName: string,
  emailSenderSignature: option(EmailSenderSignature.t),
};

let decodeProps = json =>
  Json.Decode.{
    schoolName: json |> field("schoolName", string),
    emailSenderSignature:
      json
      |> optional(field("emailSenderSignature", EmailSenderSignature.decode)),
  };

let props =
  DomUtils.parseJSONTag(~id="schools-configuration-data", ()) |> decodeProps;

ReactDOMRe.renderToElementWithId(
  <SchoolsConfiguration__Root
    schoolName={props.schoolName}
    emailSenderSignature={props.emailSenderSignature}
  />,
  "schools-configuration-root",
);
