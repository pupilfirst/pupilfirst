[@bs.config {jsx: 3}];
[@react.component]
let make = (~selected, ~contents, ~right=false) => {
  let (showDropDown, setShowDropDown) = React.useState(() => false);
  <div
    className="dropdown inline-block relative text-sm w-full md:w-auto"
    onClick={_ => setShowDropDown(showDropDown => !showDropDown)}>
    <div> selected </div>
    {
      showDropDown ?
        <ul
          className={
            "dropdown__list bg-white overflow-y-auto shadow-lg rounded mt-1 border border-gray-400 absolute overflow-hidden min-w-full md:w-auto z-20 "
            ++ (right ? "right-0" : "left-0")
          }>
          {
            contents
            |> Array.mapi((index, content) =>
                 <li
                   key={"dropdown-" ++ (index |> string_of_int)}
                   className="cursor-pointer block text-sm font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200 md:whitespace-no-wrap">
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