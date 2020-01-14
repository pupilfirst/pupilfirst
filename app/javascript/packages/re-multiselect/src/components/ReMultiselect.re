// [@bs.config {jsx: 3}];
// exception RootElementMissing(string);
// [%bs.raw {|require("./ReMultiselect.css")|}];
// module OptionUtils = {
//   let map = (f, v) =>
//     switch (v) {
//     | Some(v) => Some(f(v))
//     | None => None
//     };
// };
// let str = React.string;
// module Selectable = ReMultiselect__Selectable;
// open Webapi.Dom;
// let focus = id => {
//   (
//     switch (document |> Document.getElementById(id)) {
//     | Some(el) => el
//     | None => raise(RootElementMissing(id))
//     }
//   )
//   |> Element.asHtmlElement
//   |> OptionUtils.map(HtmlElement.focus)
//   |> ignore;
// };
// let selectionTitle = selection => {
//   let item = selection |> Selectable.item;
//   switch (selection |> Selectable.label) {
//   | Some(label) => "Pick " ++ label ++ ": " ++ item
//   | None => "Pick " ++ item
//   };
// };
// let tagPillClasses = (color, showHover) => {
//   let bgColor200 = "bg-" ++ color ++ "-200 ";
//   let bgColor300 = "bg-" ++ color ++ "-300 ";
//   let textColor800 = "text-" ++ color ++ "-800 ";
//   let textColor900 = "text-" ++ color ++ "-900 ";
//   "rounded text-xs overflow-hidden "
//   ++ bgColor200
//   ++ textColor800
//   ++ (
//     showHover
//       ? "px-2 py-px hover:" ++ bgColor300 ++ "hover:" ++ textColor900
//       : " inline-flex mt-1 mr-1"
//   );
// };
// let applyFilter = (selection, updateSelectionCB, event) => {
//   event |> ReactEvent.Mouse.preventDefault;
//   updateSelectionCB(selection);
//   focus("reMultiselect__search-input");
// };
// let searchResult = (searchInput, unselected, labelSuffix, updateSelectionCB) => {
//   // Remove all excess space characters from the user input.
//   let normalizedString = {
//     searchInput
//     |> Js.String.trim
//     |> Js.String.replaceByRe(
//          Js.Re.fromStringWithFlags("\\s+", ~flags="g"),
//          " ",
//        );
//   };
//   switch (normalizedString) {
//   | "" => [||]
//   | searchString =>
//     let matchingSelections = unselected |> Selectable.search(searchString);
//     matchingSelections
//     |> Array.mapi((index, selection) =>
//          <button
//            key={index |> string_of_int}
//            title={selectionTitle(selection)}
//            className="flex text-xs py-1 items-center w-full hover:bg-gray-200 focus:outline-none focus:bg-gray-200"
//            onClick={applyFilter(selection, updateSelectionCB)}>
//            {switch (selection |> Selectable.label) {
//             | Some(label) =>
//               <span className="mr-2 w-1/6 text-right">
//                 {label ++ labelSuffix |> str}
//               </span>
//             | None => React.null
//             }}
//            <span
//              className={tagPillClasses(selection |> Selectable.color, true)}>
//              {selection |> Selectable.item |> str}
//            </span>
//          </button>
//        );
//   };
// };
// let removeSelection = (clearSelectionCB, selection, event) => {
//   event |> ReactEvent.Mouse.preventDefault;
//   clearSelectionCB(selection);
// };
// let showSelected = (clearSelectionCB, labelSuffix, selected) => {
//   selected
//   |> Array.mapi((index, selection) => {
//        let item = selection |> Selectable.item;
//        <div
//          key={index |> string_of_int}
//          className={tagPillClasses(selection |> Selectable.color, false)}>
//          <span className="pl-2 py-px">
//            {(
//               switch (selection |> Selectable.label) {
//               | Some(label) => label ++ labelSuffix ++ item
//               | None => item
//               }
//             )
//             |> str}
//          </span>
//          <button
//            title={"Remove selection: " ++ item}
//            className="ml-1 text-red-700 px-2 py-px flex focus:outline-none hover:bg-red-400 hover:text-white"
//            onClick={removeSelection(clearSelectionCB, selection)}
//            //  <Icon className="if i-times-light" />
//          />
//        </div>;
//      });
// };
// [@react.component]
// let make =
//     (
//       ~unselected,
//       ~selected,
//       ~updateSelectionCB,
//       ~clearSelectionCB,
//       ~value,
//       ~onChange,
//       ~labelSuffix=": ",
//     ) => {
//   <div className="w-full relative">
//     <div>
//       <label
//         className="block text-tiny uppercase font-semibold"
//         htmlFor="reMultiselect__search-input">
//         {"Filter by:" |> str}
//       </label>
//       <div
//         className="flex flex-wrap items-center text-sm bg-white border border-gray-400 rounded w-full pt-1 pb-2 px-3 mt-1 focus:outline-none focus:bg-white focus:border-primary-300">
//         {selected
//          |> showSelected(clearSelectionCB, labelSuffix)
//          |> React.array}
//         <input
//           autoComplete="off"
//           value
//           onChange={e => onChange(ReactEvent.Form.target(e)##value)}
//           className="flex-grow mt-1 appearance-none bg-transparent border-none text-gray-700 mr-3 py-1 leading-snug focus:outline-none"
//           id="reMultiselect__search-input"
//           type_="text"
//           placeholder="Type name, tag or level"
//         />
//       </div>
//     </div>
//     <div />
//     {if (value |> String.trim != "") {
//        <div
//          className="ReMultiselect__search-dropdown w-full absolute border border-gray-400 bg-white mt-1 rounded-lg shadow-lg px-4 py-2">
//          {searchResult(value, unselected, labelSuffix, updateSelectionCB)
//           |> React.array}
//        </div>;
//      } else {
//        React.null;
//      }}
//   </div>;
// };
