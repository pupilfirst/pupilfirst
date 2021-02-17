%bs.raw(`require("./EditorDrawer.css")`)

open React

type size =
  | Small
  | Normal
  | Large

let drawerClasses = (size, level, previousLevel) => {
  let defaultClasses = "editor-drawer"

  let sizeClass = switch size {
  | Small => " editor-drawer--small"
  | Normal => ""
  | Large => " editor-drawer--large"
  }

  let pLevel = previousLevel.current

  let animationClass = switch (level, pLevel) {
  | (1, 0) => " editor-drawer--l0-to-l1"
  | (0, 1) => " editor-drawer--l1-to-l0"
  | (0, 0) => " editor-drawer--l0"
  | (1, 1) => " editor-drawer--l1"
  | _ => " editor-drawer--l0"
  }

  previousLevel.current = level

  defaultClasses ++ sizeClass ++ animationClass
}

@react.component
let make = (
  ~closeDrawerCB,
  ~closeButtonTitle="Close Editor",
  ~size=Normal,
  ~closeIconClassName="if i-times-regular",
  ~level=0,
  ~children,
) => {
  let previousLevel = React.useRef(level)
  React.useEffect(() => {
    ScrollLock.activate()
    Some(() => ScrollLock.deactivate())
  })
  <div>
    <div className="blanket" />
    // <div className="editor-drawer__background" />
    <div className={drawerClasses(size, level, previousLevel)}>
      <div className="editor-drawer__close hidden md:block absolute">
        <button
          onClick={e => {
            e |> ReactEvent.Mouse.preventDefault
            closeDrawerCB()
          }}
          title=closeButtonTitle
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-700 focus:outline-none mt-4">
          <Icon className={closeIconClassName ++ " text-xl"} />
        </button>
      </div>
      <div className="w-full relative overflow-y-scroll">
        <div className="md:hidden absolute right-0 pt-3 pr-4 z-50">
          <button
            onClick={e => {
              e |> ReactEvent.Mouse.preventDefault
              closeDrawerCB()
            }}
            title=closeButtonTitle
            className="flex items-center justify-center w-10 h-10 bg-gray-300 text-gray-800 font-bold p-3 rounded-full hover:bg-gray-100 hover:text-gray-900 focus:outline">
            <Icon className={closeIconClassName ++ " text-xl"} />
          </button>
        </div>
        children
      </div>
    </div>
  </div>
}
