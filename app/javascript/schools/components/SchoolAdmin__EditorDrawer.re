let component =
  ReasonReact.statelessComponent("SchoolCustomize__EditorDrawer");

let make = (~closeDrawerCB, children) => {
  ...component,
  render: _self =>
    <div>
      <div className="blanket" />
      <div className="drawer-right">
        <div className="drawer-right__close absolute">
          <button
            onClick={
              e => {
                e |> ReactEvent.Mouse.preventDefault;
                closeDrawerCB();
              }
            }
            className="flex items-center justify-center bg-white text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
            <i className="material-icons"> {"close" |> ReasonReact.string} </i>
          </button>
        </div>
        <div className="w-full overflow-scroll">
          {children |> ReasonReact.array}
        </div>
      </div>
    </div>,
};