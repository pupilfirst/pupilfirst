type size =
  | Normal
  | Large

let tr = I18n.t(~scope="components.SchoolAdmin__EditorDrawer")

let drawerClasses = size => {
  let defaultClasses = "drawer-right"

  defaultClasses ++
  switch size {
  | Normal => ""
  | Large => " drawer-right-large"
  }
}

@react.component
let make = (~closeDrawerCB, ~closeButtonTitle=tr("close_editor"), ~size=Normal, ~children) =>
  <div>
    <div className="blanket" />
    <div className={drawerClasses(size)}>
      <div className="drawer-right__close absolute">
        <button
          onClick={e => {
            e |> ReactEvent.Mouse.preventDefault
            closeDrawerCB()
          }}
          title=closeButtonTitle
          ariaLabel=closeButtonTitle
          className="flex items-center justify-center bg-white text-gray-600 font-bold py-3 px-5 rounded-s-full rounded-e-none hover:text-primary-700 focus:outline-none focus:text-primary-700 mt-4">
          <i className="fas fa-times text-xl" />
        </button>
      </div>
      <div className="w-full overflow-y-scroll"> children </div>
    </div>
  </div>
