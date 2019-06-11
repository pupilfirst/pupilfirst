[@bs.config {jsx: 3}];
[%bs.raw {|require("./MarkDownEditor.css")|}];

module TextArea = {
  open Webapi.Dom;

  external unsafeAsHtmlInputElement: Dom.element => Dom.htmlInputElement =
    "%identity";

  let setStyleHeight: (string, Dom.htmlInputElement) => unit = [%raw
    "(height, element) => { element.style.height = height; return }"
  ];

  let element = id =>
    document
    |> Document.getElementById(id)
    |> OptionUtils.unwrapUnsafely
    |> unsafeAsHtmlInputElement;

  let selectionStart = id => element(id) |> HtmlInputElement.selectionStart;

  let selectionEnd = id => element(id) |> HtmlInputElement.selectionEnd;

  let fitContent = id => {
    let e = id |> element;

    /* Store the original window scroll height. It'll get messed up when we change the height of the textarea to auto. */
    let windowScrollHeight = Window.scrollY(window);

    /* Set height of the element to auto to be able to calculate its true scrollHeight. */
    e |> setStyleHeight("auto");

    /*
     * Calculate true height, adding an additional 18 pixels to make sure that
     * addition of line breaks does not cause the textarea to scroll up.
     */
    let height =
      ((e |> HtmlInputElement.scrollHeight) + 18 |> string_of_int) ++ "px";

    e |> setStyleHeight(height);

    /* Restore original window scroll height. */
    window |> Window.scrollTo(0.0, windowScrollHeight);
  };
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
    (id, description, setDescription, updateDescriptionCB, action, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  let actionString =
    switch (action) {
    | Bold => "**"
    | Italics => "*"
    | Code => "`"
    };

  let start = TextArea.selectionStart(id);
  let finish = TextArea.selectionEnd(id);
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
  <span>
    {
      switch (action) {
      | Bold => <i className="far fa-bold" />
      | Italics => <i className="far fa-italic" />
      | Code => <i className="far fa-code" />
      }
    }
  </span>;

type previewButtonPosition =
  | PositionRight
  | PositionLeft;

let buttons =
    (
      id,
      description,
      setDescription,
      updateDescriptionCB,
      preview,
      setPreview,
      previewButtonPosition,
    ) => {
  let classes = "markdown-button-group__button hover:bg-primary-100 hover:text-primary-400 focus:outline-none focus:text-primary-600";

  let previewOrEditButton =
    (
      switch (description) {
      | "" => React.null
      | _someDescription =>
        <button
          key="preview-button"
          className=classes
          onClick=(_ => setPreview(_ => !preview))>
          {
            preview ?
              <FaIcon classes="fab fa-markdown" /> :
              <FaIcon classes="far fa-eye" />
          }
          <span className="ml-2">
            {(preview ? "Edit Markdown" : "Preview") |> str}
          </span>
        </button>
      }
    )
    |> Array.make(1);

  let styleButtons =
    [|Bold, Italics, Code|]
    |> Array.map(action =>
         <button
           className=classes
           key={action |> buttonTitle}
           title={action |> buttonTitle}
           onClick={
             handleClick(
               id,
               description,
               setDescription,
               updateDescriptionCB,
               action,
             )
           }>
           {action |> buttonIcon}
         </button>
       );

  (
    switch (previewButtonPosition) {
    | PositionLeft => Array.append(previewOrEditButton, styleButtons)
    | PositionRight => Array.append(styleButtons, previewOrEditButton)
    }
  )
  |> React.array;
};

[@react.component]
let make = (~placeholder=?, ~updateDescriptionCB, ~value, ~label=?) => {
  let (description, setDescription) = React.useState(() => value);
  let (preview, setPreview) = React.useState(() => false);
  let (id, _setId) =
    React.useState(() =>
      "markdown-editor-"
      ++ (Js.Math.random_int(100000, 999999) |> string_of_int)
    );

  let (label, previewButtonPosition) =
    switch (label) {
    | Some(label) => (
        <label
          className="inline-block tracking-wide text-gray-700 text-xs font-semibold"
          htmlFor=id>
          {label |> str}
        </label>,
        PositionLeft,
      )
    | None => (React.null, PositionRight)
    };

  React.useEffect(() => {
    if (!preview) {
      TextArea.fitContent(id);
    };

    None;
  });

  <div>
    <div className="flex justify-between items-end">
      label
      <div className="flex markdown-button-group">
        {
          buttons(
            id,
            description,
            setDescription,
            updateDescriptionCB,
            preview,
            setPreview,
            previewButtonPosition,
          )
        }
      </div>
    </div>
    {
      preview ?
        <MarkdownBlock
          markdown=description
          className="py-3 leading-normal text-sm px-3 border border-transparent bg-gray-100 markdown-editor-preview mt-2"
        /> :
        <textarea
          id
          maxLength=1000
          rows=6
          ?placeholder
          value=description
          onChange={
            event =>
              updateDescription(
                ReactEvent.Form.target(event)##value,
                setDescription,
                updateDescriptionCB,
              )
          }
          className="overflow-y-hidden appearance-none block w-full text-sm bg-white text-gray-800 border border-gray-400 rounded p-3 leading-normal focus:outline-none focus:bg-white focus:border-gray-500 mt-2"
        />
    }
  </div>;
};

module Jsx2 = {
  let component = ReasonReact.statelessComponent("MarkDownEditor");

  let make = (~placeholder, ~updateDescriptionCB, ~value, ~label, children) =>
    ReasonReactCompat.wrapReactForReasonReact(
      make,
      makeProps(~placeholder, ~updateDescriptionCB, ~value, ~label, ()),
      children,
    );
};