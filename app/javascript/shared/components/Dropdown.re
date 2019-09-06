[@bs.config {jsx: 3}];
[@react.component]
let make = (~selected, ~contents, ~right=false) => {
  let (showDropDown, setShowDropDown) = React.useState(() => false);
  <div
    className="dropdown inline-block relative text-sm"
    onClick={_ => setShowDropDown(showDropDown => !showDropDown)}>
    <div> selected </div>
    {
      showDropDown ?
        <ul
          className={
            "dropdown__list bg-white shadow-lg rounded mt-1 border border-gray-400 absolute overflow-hidden min-w-full w-auto z-20 "
            ++ (right ? "right-0" : "left-0")
          }>
          {
            contents
            |> Array.map(content =>
                 <li
                   className="cursor-pointer block text-sm font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200 whitespace-no-wrap">
                   content
                 </li>
               )
            |> React.array
          }
        </ul> :
        React.null
    }
  </div>;
};