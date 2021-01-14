%bs.raw(`require("./SchoolAdmin__EditorDrawer2.css")`)

open React

let drawerClasses = (size, level, previousLevel) => {
  let defaultClasses = "editor-drawer-2"

  let sizeClass = switch size {
  | SchoolAdmin__EditorDrawer.Normal => ""
  | Large => " editor-drawer-2--large"
  }

  let pLevel = previousLevel.current

  let animationClass = switch (level, pLevel) {
  | (1, 0) => " editor-drawer-2--l0-to-l1"
  | (0, 1) => " editor-drawer-2--l1-to-l0"
  | (0, 0) => " editor-drawer-2--l0"
  | (1, 1) => " editor-drawer-2--l1"
  | _ => " editor-drawer-2--l0"
  }

  previousLevel.current = level

  defaultClasses ++ (sizeClass ++ animationClass)
}

@react.component
let make = (
  ~closeDrawerCB,
  ~closeButtonTitle="Close Editor",
  ~size=SchoolAdmin__EditorDrawer.Normal,
  ~closeIconClassName="fas fa-times",
  ~level=0,
  ~children,
) => {
  let previousLevel = React.useRef(level)

  <div>
    <div className="blanket" />
    // <div className="editor-drawer-2__background" />
    <div className={drawerClasses(size, level, previousLevel)}>
      <div className="editor-drawer-2__close absolute">
        <button
          onClick={e => {
            e |> ReactEvent.Mouse.preventDefault
            closeDrawerCB()
          }}
          title=closeButtonTitle
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-700 focus:outline-none mt-4">
          <i className={closeIconClassName ++ " text-xl"} />
        </button>
      </div>
      <div className="w-full overflow-y-scroll"> children </div>
    </div>
  </div>
}
