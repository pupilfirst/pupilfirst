[@bs.config {jsx: 3}];

let str = React.string;

type fullscreenMode = [ | `Editor | `Preview | `Split];

type windowedMode = [ | `Editor | `Preview];

type mode =
  | Fullscreen(fullscreenMode)
  | Windowed(windowedMode);

type selection = (selectionStart, selectionEnd)
and selectionStart = int
and selectionEnd = int;

type state = {
  id: string,
  mode,
  selection,
};

type action =
  | ClickPreview
  | ClickSplit
  | ClickFullscreen
  | SetSelection(selection)
  | PressEscapeKey;

let reducer = (state, action) =>
  switch (action) {
  | ClickPreview =>
    let mode =
      switch (state.mode) {
      | Windowed(`Preview) => Windowed(`Editor)
      | Windowed(`Editor) => Windowed(`Preview)
      | Fullscreen(`Editor)
      | Fullscreen(`Split) => Fullscreen(`Preview)
      | Fullscreen(`Preview) => Fullscreen(`Editor)
      };
    {...state, mode};
  | ClickSplit =>
    let mode =
      switch (state.mode) {
      | Windowed(_) => Fullscreen(`Split)
      | Fullscreen(`Editor)
      | Fullscreen(`Preview) => Fullscreen(`Split)
      | Fullscreen(`Split) => Fullscreen(`Editor)
      };
    {...state, mode};
  | ClickFullscreen =>
    let mode =
      switch (state.mode) {
      | Windowed(`Editor) => Fullscreen(`Editor)
      | Windowed(`Preview) => Fullscreen(`Preview)
      | Fullscreen(`Editor) => Windowed(`Editor)
      | Fullscreen(`Preview) => Windowed(`Preview)
      | Fullscreen(`Split) => Windowed(`Editor)
      };
    {...state, mode};
  | SetSelection(selection) => {...state, selection}
  | PressEscapeKey =>
    let mode =
      switch (state.mode) {
      | Fullscreen(`Editor) => Windowed(`Editor)
      | Windowed(`Preview)
      | Fullscreen(`Preview) => Windowed(`Preview)
      | Windowed(`Editor)
      | Fullscreen(`Split) => Windowed(`Editor)
      };
    {...state, mode};
  };

let computeInitialState = ((value, textareaId, mode)) => {
  let id =
    switch (textareaId) {
    | Some(id) => id
    | None => DateTime.randomId()
    };

  let length = value |> String.length;

  {id, mode, selection: (length, length)};
};

let containerClasses = mode =>
  switch (mode) {
  | Windowed(_) => ""
  | Fullscreen(_) => "bg-white fixed z-50 top-0 left-0 h-screen w-screen flex flex-col"
  };

let modeIcon = (desiredMode, currentMode) => {
  let icon =
    switch (desiredMode, currentMode) {
    | (
        `Preview,
        Windowed(`Editor) | Fullscreen(`Editor) | Fullscreen(`Split),
      ) => "fas fa-eye"
    | (`Preview, Windowed(`Preview) | Fullscreen(`Preview)) => "fas fa-pen-nib"
    | (`Split, Windowed(_) | Fullscreen(`Editor) | Fullscreen(`Preview)) => "fas fa-columns"
    | (`Split, Fullscreen(`Split)) => "far fa-window-maximize"
    | (`Fullscreen, Windowed(_)) => "fas fa-expand"
    | (`Fullscreen, Fullscreen(_)) => "fas fa-compress"
    };

  <FaIcon classes={"fa-fw " ++ icon} />;
};

let onClickFullscreen = (state, send, _event) => {
  switch (state.mode) {
  | Windowed(_) => TextareaAutosize.destroy(state.id)
  | Fullscreen(_) => () // Do nothing here. We'll fix this in an effect.
  };

  send(ClickFullscreen);
};

let onClickPreview = (state, send, _event) => {
  switch (state.mode) {
  | Windowed(`Editor) => TextareaAutosize.destroy(state.id)
  | Windowed(`Preview)
  | Fullscreen(_) => () // Do nothing here. We'll fix this in an effect.
  };

  send(ClickPreview);
};

let onClickSplit = (state, send, _event) => {
  switch (state.mode) {
  | Windowed(_) => TextareaAutosize.destroy(state.id)
  | Fullscreen(_) => () // This should have no effect on textarea autosizing in full-screen mode.
  };

  send(ClickSplit);
};

let insertAt = (textToInsert, position, sourceText) => {
  let head = sourceText->String.sub(0, position);
  let tail =
    sourceText->String.sub(
      position,
      (sourceText |> String.length) - position,
    );

  head ++ textToInsert ++ tail;
};

let wrapWith = (wrapper, selectionStart, selectionEnd, sourceText) => {
  let head = sourceText->String.sub(0, selectionStart);
  let selection =
    sourceText->String.sub(selectionStart, selectionEnd - selectionStart);
  let tail =
    sourceText->String.sub(
      selectionEnd,
      (sourceText |> String.length) - selectionEnd,
    );

  head ++ wrapper ++ selection ++ wrapper ++ tail;
};

let updateTextareaAfterDelay = state =>
  switch (state.mode) {
  | Windowed(_) =>
    Js.Global.setTimeout(() => TextareaAutosize.update(state.id), 100)
    |> ignore
  | Fullscreen(_) => () // Autosizing is turned off in full-screen mode.
  };

let onClickPhraseModifier =
    (value, state, onChange, ~insert, ~wrapper, _event) => {
  let (selectionStart, selectionEnd) = state.selection;

  let newValue =
    if (selectionStart == selectionEnd) {
      value |> insertAt(insert, selectionStart);
    } else {
      value |> wrapWith(wrapper, selectionStart, selectionEnd);
    };

  onChange(newValue);
  updateTextareaAfterDelay(state);
};

let controls = (value, state, send, onChange) => {
  let buttonClasses = "border rounded-lg p-1 bg-gray-200 hover:bg-gray-300 ";
  let {mode} = state;

  <div className="bg-gray-100 p-1 flex justify-between">
    <div>
      <button
        className=buttonClasses
        onClick={onClickPhraseModifier(
          value,
          state,
          onChange,
          ~insert="**bold**",
          ~wrapper="**",
        )}>
        <FaIcon classes="fas fa-bold fa-fw" />
      </button>
      <button
        className={buttonClasses ++ "ml-2"}
        onClick={onClickPhraseModifier(
          value,
          state,
          onChange,
          ~insert="*italics*",
          ~wrapper="*",
        )}>
        <FaIcon classes="fas fa-italic fa-fw" />
      </button>
      <button
        className={buttonClasses ++ "ml-2"}
        onClick={onClickPhraseModifier(
          value,
          state,
          onChange,
          ~insert="~~strikethrough~~",
          ~wrapper="~~",
        )}>
        <FaIcon classes="fas fa-strikethrough fa-fw" />
      </button>
    </div>
    <div>
      <button className=buttonClasses onClick={onClickPreview(state, send)}>
        {modeIcon(`Preview, mode)}
      </button>
      <button
        className={buttonClasses ++ "ml-2"}
        onClick={onClickSplit(state, send)}>
        {modeIcon(`Split, mode)}
      </button>
      <button
        className={buttonClasses ++ "ml-2"}
        onClick={onClickFullscreen(state, send)}>
        {modeIcon(`Fullscreen, mode)}
        {switch (mode) {
         | Fullscreen(_) =>
           <span className="ml-2"> {"Exit full-screen" |> str} </span>
         | Windowed(_) => React.null
         }}
      </button>
    </div>
  </div>;
};

let modeClasses = mode =>
  switch (mode) {
  | Windowed(_) => ""
  | Fullscreen(_) => "flex flex-grow"
  };

let editorContainerClasses = mode =>
  "border "
  ++ (
    switch (mode) {
    | Windowed(`Editor) => ""
    | Windowed(`Preview) => "hidden"
    | Fullscreen(`Editor) => "w-full"
    | Fullscreen(`Preview) => "hidden"
    | Fullscreen(`Split) => "w-1/2"
    }
  );

let previewContainerClasses = mode =>
  "px-2 "
  ++ (
    switch (mode) {
    | Windowed(`Editor) => "hidden"
    | Windowed(`Preview) => ""
    | Fullscreen(`Editor) => "hidden"
    | Fullscreen(`Preview) => "w-full"
    | Fullscreen(`Split) => "w-1/2"
    }
  );

let focusOnEditor = id => {
  Webapi.Dom.(
    document
    |> Document.getElementById(id)
    |> OptionUtils.flatMap(HtmlElement.ofElement)
    |> OptionUtils.mapWithDefault(element => element |> HtmlElement.focus, ())
  );
};

let footer = <div className="bg-gray-100 p-1"> {"Footer" |> str} </div>;

let textareaClasses = mode => {
  "w-full p-2 outline-none "
  ++ (
    switch (mode) {
    | Windowed(_) => ""
    | Fullscreen(_) => "h-full resize-none"
    }
  );
};

let onChangeWrapper = (onChange, event) => {
  let value = ReactEvent.Form.target(event)##value;
  onChange(value);
};

let onSelect = (send, event) => {
  let htmlInputElement =
    ReactEvent.Selection.target(event)
    |> DomUtils.EventTarget.unsafeToHtmlInputElement;

  let selection =
    Webapi.Dom.(
      htmlInputElement |> HtmlInputElement.selectionStart,
      htmlInputElement |> HtmlInputElement.selectionEnd,
    );

  send(SetSelection(selection));
};

let handleEscapeKey = (send, event) =>
  switch (event |> Webapi.Dom.KeyboardEvent.key) {
  | "Escape" => send(PressEscapeKey)
  | _anyOtherKey => ()
  };

[@react.component]
let make =
    (
      ~value,
      ~onChange,
      ~profile,
      ~textareaId=?,
      ~maxLength=1000,
      ~defaultMode=Windowed(`Editor),
    ) => {
  let (state, send) =
    React.useReducerWithMapState(
      reducer,
      (value, textareaId, defaultMode),
      computeInitialState,
    );

  // Reset autosize when switching from full-screen mode.
  React.useEffect1(
    () => {
      switch (state.mode) {
      | Windowed(`Editor) => TextareaAutosize.create(state.id)
      | Windowed(`Preview)
      | Fullscreen(_) => () // Do nothing. This was handled in the click handler.
      };

      Some(() => TextareaAutosize.destroy(state.id));
    },
    [|state.mode|],
  );

  // Use Escape key to close full-screen mode.
  React.useEffect0(() => {
    let curriedHandler = handleEscapeKey(send);
    let documentEventTarget = Webapi.Dom.(document |> Document.asEventTarget);

    documentEventTarget
    |> Webapi.Dom.EventTarget.addKeyUpEventListener(curriedHandler);

    Some(
      () =>
        documentEventTarget
        |> Webapi.Dom.EventTarget.removeKeyUpEventListener(curriedHandler),
    );
  });

  <div className={containerClasses(state.mode)}>
    {controls(value, state, send, onChange)}
    <div className={modeClasses(state.mode)}>
      <div className={editorContainerClasses(state.mode)}>
        <textarea
          rows=4
          maxLength
          onSelect={onSelect(send)}
          onChange={onChangeWrapper(onChange)}
          id={state.id}
          value
          className={textareaClasses(state.mode)}
        />
      </div>
      <div className={previewContainerClasses(state.mode)}>
        <MarkdownBlock markdown=value profile />
      </div>
    </div>
    footer
  </div>;
};
