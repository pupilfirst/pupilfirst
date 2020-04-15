[%bs.raw {|require("./PrintCertificate__Root.css")|}];

let str = React.string;

let printCertificate = () => Webapi.Dom.(window |> Window.print);

[@react.component]
let make = (~issuedCertificate, ~verifyImageUrl) => {
  React.useEffect(() => {
    printCertificate();
    None;
  });

  <IssuedCertificate__Root
    issuedCertificate
    verifyImageUrl
    maxWidth=1600
    minWidth=1600
  />;
};
