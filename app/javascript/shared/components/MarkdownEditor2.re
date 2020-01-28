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
  | Fullscreen(_) => "bg-white fixed z-50 top-0 left-0 h-screen w-screen"
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

  <FaIcon classes={"fas " ++ icon} />;
};

let controls = (send, mode) => {
  let buttonClasses = "btn btn-primary ml-2 p-1";

  <div>
    <button className=buttonClasses onClick={_ => send(ClickPreview)}>
      {modeIcon(`Preview, mode)}
    </button>
    <button className=buttonClasses onClick={_ => send(ClickSplit)}>
      {modeIcon(`Split, mode)}
    </button>
    <button className=buttonClasses onClick={_ => send(ClickFullscreen)}>
      {modeIcon(`Fullscreen, mode)}
    </button>
  </div>;
};

let modeClasses = mode =>
  switch (mode) {
  | Windowed(_) => ""
  | Fullscreen(_) => "flex"
  };

let editorContainerClasses = mode =>
  switch (mode) {
  | Windowed(`Editor) => ""
  | Windowed(`Preview) => "hidden"
  | Fullscreen(`Editor) => "w-full"
  | Fullscreen(`Preview) => "hidden"
  | Fullscreen(`Split) => "w-1/2"
  };
let previewContainerClasses = mode =>
  switch (mode) {
  | Windowed(`Editor) => "hidden"
  | Windowed(`Preview) => ""
  | Fullscreen(`Editor) => "hidden"
  | Fullscreen(`Preview) => "w-full"
  | Fullscreen(`Split) => "w-1/2"
  };

[@react.component]
let make = (~value, ~onChange) => {
  let (state, send) =
    React.useReducerWithMapState(reducer, (), computeInitialState);

  React.useEffect0(() => {
    TextareaAutosize.create(state.id);
    Some(() => TextareaAutosize.destroy(state.id));
  });

  <div className={containerClasses(state.mode)}>
    {controls(send, state.mode)}
    <div className={modeClasses(state.mode)}>
      <div className={editorContainerClasses(state.mode)}>
        <textarea
          onChange
          id={state.id}
          value
          className="w-full h-full border p-2"
        />
      </div>
      <div className={previewContainerClasses(state.mode)}>
        <MarkdownBlock markdown=value profile=Markdown.Permissive />
      </div>
    </div>
  </div>;
};
