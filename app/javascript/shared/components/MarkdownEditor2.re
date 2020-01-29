[@bs.config {jsx: 3}];

let str = React.string;

type fullscreenMode = [ | `Editor | `Preview | `Split];

type windowedMode = [ | `Editor | `Preview];

type mode =
  | Fullscreen(fullscreenMode)
  | Windowed(windowedMode);

type state = {
  id: string,
  mode,
};

type action =
  | ClickPreview
  | ClickSplit
  | ClickFullscreen;

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
  };

let computeInitialState = () => {
  id: DateTime.randomId(),
  mode: Windowed(`Editor),
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
      ) => "fa-eye"
    | (`Preview, Windowed(`Preview) | Fullscreen(`Preview)) => "fa-pen-nib"
    | (`Split, Windowed(_) | Fullscreen(`Editor) | Fullscreen(`Preview)) => "fa-columns"
    | (`Split, Fullscreen(`Split)) => "fa-window-maximize"
    | (`Fullscreen, Windowed(_)) => "fa-expand"
    | (`Fullscreen, Fullscreen(_)) => "fa-compress"
    };

  <FaIcon classes={"fas fa-fw " ++ icon} />;
};

let onClickFullscreen = (state, send, _event) => {
  switch (state.mode) {
  | Windowed(_) => TextareaAutosize.destroy(state.id)
  | Fullscreen(_) => () // Do nothing here. We'll fix this in an effect.
  };

  send(ClickFullscreen);
};

let onClickSplit = (state, send, event) => {
  switch (state.mode) {
  | Windowed(_) => TextareaAutosize.destroy(state.id)
  | Fullscreen(_) => () // This should have no effect on textarea autosizing in full-screen mode.
  };

  send(ClickSplit);
};

let controls = (state, send) => {
  let buttonClasses = "border rounded-lg p-1 bg-gray-200 hover:bg-gray-300 ";
  let {mode} = state;

  <div className="bg-gray-100 p-1">
    <button className=buttonClasses onClick={_ => send(ClickPreview)}>
      {modeIcon(`Preview, mode)}
    </button>
    <button
      className={buttonClasses ++ "ml-2"} onClick={onClickSplit(state, send)}>
      {modeIcon(`Split, mode)}
    </button>
    <button
      className={buttonClasses ++ "ml-2"}
      onClick={onClickFullscreen(state, send)}>
      {modeIcon(`Fullscreen, mode)}
    </button>
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

[@react.component]
let make = (~value, ~onChange) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, (), computeInitialState);

  React.useEffect0(() => {
    TextareaAutosize.create(state.id);
    Some(() => TextareaAutosize.destroy(state.id));
  });

  React.useEffect1(
    () => {
      switch (state.mode) {
      | Windowed(_) => TextareaAutosize.create(state.id)
      | Fullscreen(_) => () // Do nothing. This was handled in the click handler.
      };

      None;
    },
    [|state.mode|],
  );

  <div className={containerClasses(state.mode)}>
    {controls(state, send)}
    <div className={modeClasses(state.mode)}>
      <div className={editorContainerClasses(state.mode)}>
        <textarea
          rows=4
          onChange
          id={state.id}
          value
          className={textareaClasses(state.mode)}
        />
      </div>
      <div className={previewContainerClasses(state.mode)}>
        <MarkdownBlock markdown=value profile=Markdown.Permissive />
      </div>
    </div>
    footer
  </div>;
};
