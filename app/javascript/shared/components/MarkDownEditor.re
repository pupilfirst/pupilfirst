[@bs.config {jsx: 3}];

type element;
[@bs.scope "document"] [@bs.val]
external getElementById: string => element = "";
[@bs.get] external selectionStart: element => int = "";
[@bs.get] external selectionEnd: element => int = "";
[@bs.get] external value: element => string = "";

module TextArea = {
  open Webapi.Dom;

  external unsafeAsHtmlInputElement: Dom.element => Dom.htmlInputElement =
    "%identity";

  let element = () =>
    document
    |> Document.getElementById("mytextarea")
    |> OptionUtils.unwrapUnsafely
    |> unsafeAsHtmlInputElement;

  let selectionStart = () => element() |> HtmlInputElement.selectionStart;

  let selectionEnd = () => element() |> HtmlInputElement.selectionEnd;
};

type action =
  | Bold
  | Italics
  | Code;

let str = React.string;

let handleClick =
    (description, setDescription, updateDescriptionCB, action, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  let actionString =
    switch (action) {
    | Bold => "**"
    | Italics => "*"
    | Code => "`"
    };

  let start = TextArea.selectionStart();
  let finish = TextArea.selectionEnd();
  let sel = Js.String.substring(~from=start, ~to_=finish, description);

  let newText =
    if (start != finish) {
      Js.String.substring(~from=0, ~to_=start, description)
      ++ actionString
      ++ sel
      ++ actionString
      ++ Js.String.substring(
           ~from=finish,
           ~to_=description |> Js.String.length,
           description,
         );
    } else {
      description
      ++ (
        switch (action) {
        | Bold => "**strong text**"
        | Italics => "*emphasized text*"
        | Code => "`enter code here`"
        }
      );
    };
  setDescription(_ => newText);
  updateDescriptionCB(newText);
};

let buttonTitle = action =>
  switch (action) {
  | Bold => "Bold"
  | Italics => "Italics"
  | Code => "Code"
  };

let buttons = (description, setDescription, updateDescriptionCB) =>
  [|Bold, Italics, Code|]
  |> Array.map(action =>
       <button
         className="border p-2"
         key={action |> buttonTitle}
         onClick={
           handleClick(
             description,
             setDescription,
             updateDescriptionCB,
             action,
           )
         }>
         {action |> buttonTitle |> str}
       </button>
     )
  |> React.array;

[@react.component]
let make = (~placeholderText, ~updateDescriptionCB) => {
  let (description, setDescription) = React.useState(() => "");
  let (showPreview, setShowPreview) = React.useState(() => false);

  <div>
    <div className="flex w-full justify-between py-2">
      {
        showPreview ?
          <div> {"Preview" |> str} </div> :
          <div className="flex w-full ">
            {buttons(description, setDescription, updateDescriptionCB)}
          </div>
      }
      <button
        className="border p-2"
        onClick={_ => setShowPreview(_ => !showPreview)}>
        {(showPreview ? "Edit" : "Preview") |> str}
      </button>
    </div>
    {
      showPreview ?
        <div
          className="py-4 px-6 leading-normal text-sm"
          dangerouslySetInnerHTML={"__html": description |> Markdown.parse}
        /> :
        <textarea
          id="mytextarea"
          maxLength=1000
          placeholder=placeholderText
          value=description
          onChange={
            event => setDescription(ReactEvent.Form.target(event)##value)
          }
          className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
        />
    }
  </div>;
};