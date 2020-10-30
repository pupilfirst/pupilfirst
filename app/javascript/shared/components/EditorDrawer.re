[%bs.raw {|require("./EditorDrawer.css")|}];

open React;

type size =
  | Normal
  | Large;

let drawerClasses = (size, level, previousLevel) => {
  let defaultClasses = "editor-drawer";

  let sizeClass =
    switch (size) {
    | Normal => ""
    | Large => " editor-drawer--large"
    };

  let pLevel = previousLevel.current;

  let animationClass =
    switch (level, pLevel) {
    | (1, 0) => " editor-drawer--l0-to-l1"
    | (0, 1) => " editor-drawer--l1-to-l0"
    | (0, 0) => " editor-drawer--l0"
    | (1, 1) => " editor-drawer--l1"
    | _ => " editor-drawer--l0"
    };

  previousLevel.current = level;

  defaultClasses ++ sizeClass ++ animationClass;
};

[@react.component]
let make =
    (
      ~closeDrawerCB,
      ~closeButtonTitle="Close Editor",
      ~size=Normal,
      ~closeIconClassName="fas fa-times",
      ~level=0,
      ~children,
    ) => {
  let previousLevel = React.useRef(level);
  React.useEffect(() => {
    ScrollLock.activate();
    Some(() => ScrollLock.deactivate());
  });
  <div>
    <div className="blanket" />
    // <div className="editor-drawer__background" />
    <div className={drawerClasses(size, level, previousLevel)}>
      <div className="editor-drawer__close hidden md:block absolute">
        <button
          onClick={e => {
            e |> ReactEvent.Mouse.preventDefault;
            closeDrawerCB();
          }}
          title=closeButtonTitle
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-700 focus:outline-none mt-4">
          <i className={closeIconClassName ++ " text-xl"} />
        </button>
      </div>
      <div className="md:hidden absolute right-0">
        <button
          onClick={e => {
            e |> ReactEvent.Mouse.preventDefault;
            closeDrawerCB();
          }}
          title=closeButtonTitle
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-700 focus:outline-none mt-4">
          <i className={closeIconClassName ++ " text-xl"} />
        </button>
      </div>
      <div className="w-full overflow-y-scroll"> children </div>
    </div>
  </div>;
};
