let str = ReasonReact.string;

let component =
  ReasonReact.statelessComponent("SchoolCustomize__LinksEditor");

let handleCloseEditor = (cb, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  cb();
};

let showLinks = links =>
  links
  |> List.map(((title, url)) =>
       <div
         className="flex items-center justify-between bg-grey-lightest text-xs text-grey-darkest border rounded p-3 mt-2">
         <div className="flex items-center">
           <span> {title |> str} </span>
           <i className="material-icons text-base ml-1">
             {"arrow_forward" |> str}
           </i>
           <code className="ml-1"> {url |> str} </code>
         </div>
         <button> <Icon kind=Icon.Delete size="4" /> </button>
       </div>
     )
  |> Array.of_list
  |> ReasonReact.array;

let socialMediaLinks = links =>
  links
  |> List.map(url =>
       <div
         className="flex items-center justify-between bg-grey-lightest text-xs text-grey-darkest border rounded p-3 mt-2">
         <code> {url |> str} </code>
         <button> <Icon kind=Icon.Delete size="4" /> </button>
       </div>
     )
  |> Array.of_list
  |> ReasonReact.array;

let make =
    (~closeEditorCB, ~headerLinks, ~footerLinks, ~socialLinks, _children) => {
  ...component,
  render: _self =>
    <div>
      <div className="blanket" />
      <div className="drawer-right">
        <div className="drawer-right__close absolute">
          <button
            onClick={handleCloseEditor(closeEditorCB)}
            className="flex items-center justify-center bg-white text-grey-darker font-bold py-3 px-5 rounded-l-full rounded-r-none focus:outline-none mt-4">
            <i className="material-icons"> {"close" |> str} </i>
          </button>
        </div>
        <div className="w-full">
          <div className="mx-auto bg-white">
            <div className="max-w-md p-6 mx-auto">
              <h5
                className="uppercase text-center border-b border-grey-light pb-2">
                {"Customize Links" |> str}
              </h5>
              <label
                className="inline-block tracking-wide text-grey-darker text-xs font-semibold mt-4">
                {"Header Links" |> str}
              </label>
              {showLinks(headerLinks)}
              <label
                className="block tracking-wide text-grey-darker text-xs font-semibold mt-4">
                {"Footer Links" |> str}
              </label>
              {showLinks(footerLinks)}
              <label
                className="block tracking-wide text-grey-darker text-xs font-semibold mt-4">
                {"Social Media Links" |> str}
              </label>
              {socialMediaLinks(socialLinks)}
              <div className="flex">
                <button
                  disabled=true
                  className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-4">
                  {"Update Custom Links" |> str}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>,
};