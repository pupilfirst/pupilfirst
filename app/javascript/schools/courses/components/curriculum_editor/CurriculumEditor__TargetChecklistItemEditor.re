[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

let checklistDropdown = checklistItem => {
  let selectedKind = checklistItem |> ChecklistItem.kind;
  let selected =
    <button className="border appearance-none inline-flex items-center">
      <span className="px-2 py-2">
        {selectedKind |> ChecklistItem.actionStringForKind |> str}
      </span>
      <span className="px-2 py-2 border-l border-gray-400">
        <i className="fas fa-chevron-down text-sm" />
      </span>
    </button>;

  let contents =
    [|ChecklistItem.LongText, ShortText, Files, Link, MultiChoice, Statement|]
    |> Js.Array.filter(kind => kind != selectedKind)
    |> Array.map(kind =>
         <button> {kind |> ChecklistItem.actionStringForKind |> str} </button>
       );
  <Dropdown selected contents />;
};

[@react.component]
let make = (~checklistItem, ~index) => {
  <div className="mt-2">
    {<div
       className="flex-col bg-gray-100 mb-2 p-2" key={index |> string_of_int}>
       <div className="flex justify-between items-center">
         <div className="ml-2 flex justify-start items-center">
           <span className="font-semibold text-sm mr-2">
             {(index + 1 |> string_of_int) ++ "." |> str}
           </span>
           {checklistDropdown(checklistItem)}
         </div>
         <div className="items-center">
           <input
             className="leading-tight"
             type_="checkbox"
             id={index |> string_of_int}
             checked={checklistItem |> ChecklistItem.optional}
           />
           <label
             className="text-xs text-gray-600 ml-2"
             htmlFor={index |> string_of_int}>
             {"Optional" |> str}
           </label>
         </div>
       </div>
       <div
         className="flex items-center ml-3 text-sm bg-white border border-gray-400 rounded py-2 px-3 mt-3 focus:outline-none focus:bg-white focus:border-primary-300">
         <input
           className="flex-grow appearance-none bg-transparent border-none text-gray-700 leading-snug focus:outline-none"
           placeholder="Describe this step"
           type_="text"
           value={checklistItem |> ChecklistItem.title}
         />
       </div>
     </div>}
  </div>;
};
