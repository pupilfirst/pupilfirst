[@bs.config {jsx: 3}];
[%bs.raw {|require("./MarkDownEditor.css")|}];

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

let updateDescription = (description, setDescription, updateDescriptionCB) => {
  setDescription(_ => description);
  updateDescriptionCB(description);
};

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
        | Bold => " **strong text** "
        | Italics => " *emphasized text* "
        | Code => " `enter code here` "
        }
      );
    };
  updateDescription(newText, setDescription, updateDescriptionCB);
};

let buttonTitle = action =>
  switch (action) {
  | Bold => "Bold"
  | Italics => "Italics"
  | Code => "Code"
  };

let buttonIcon = action =>
  switch (action) {
  | Bold => <i className="far fa-bold" />
  | Italics => <i className="far fa-italic" />
  | Code => <i className="far fa-code" />
  };

let buttons = (description, setDescription, updateDescriptionCB) =>
  [|Bold, Italics, Code|]
  |> Array.map(action =>
       <button
         className="markdown-button-group__button hover:bg-primary-100 hover:text-primary-400 focus:outline-none focus:text-primary-600"
         key={action |> buttonTitle}
         title={action |> buttonTitle}
         onClick={
           handleClick(
             description,
             setDescription,
             updateDescriptionCB,
             action,
           )
         }>
         {action |> buttonIcon}
       </button>
     )
  |> React.array;

[@react.component]
let make = (~placeholderText, ~updateDescriptionCB, ~value) => {
  let (description, setDescription) = React.useState(() => value);
  let (showPreview, setShowPreview) = React.useState(() => false);
  <div title="Markdown Editor">
    <div className="flex w-full justify-between items-center py-2">
      {
        showPreview ?
          <p className="font-semibold text-sm pl-3"> {"Preview" |> str} </p> :
          <div className="flex markdown-button-group">
            {buttons(description, setDescription, updateDescriptionCB)}
          </div>
      }
      {
        description != "" ?
          <button
            className="btn btn-default"
            onClick={_ => setShowPreview(_ => !showPreview)}>
            <span>
              {
                showPreview ?
                  <FaIcon classes="far fa-edit" /> :
                  <FaIcon classes="far fa-eye" />
              }
            </span>
            <span className="ml-2">
              {(showPreview ? "Edit" : "Preview") |> str}
            </span>
          </button> :
          React.null
      }
    </div>
    {
      showPreview ?
        <div
          className="p-3 leading-normal text-sm markdown-body"
          dangerouslySetInnerHTML={"__html": description |> Markdown.parse}
        /> :
        <textarea
          id="mytextarea"
          title="Markdown input"
          maxLength=1000
          rows=6
          placeholder=placeholderText
          value=description
          onChange={
            event =>
              updateDescription(
                ReactEvent.Form.target(event)##value,
                setDescription,
                updateDescriptionCB,
              )
          }
          className="appearance-none block w-full bg-white text-gray-700 border border-gray-400 rounded p-3 leading-tight focus:outline-none focus:bg-white focus:border-gray"
        />
    }
  </div>;
};