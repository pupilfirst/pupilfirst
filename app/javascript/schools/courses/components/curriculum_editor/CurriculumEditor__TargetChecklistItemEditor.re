[@bs.config {jsx: 3}];

open CurriculumEditor__Types;

let str = React.string;

let updateTitle = (checklistItem, updateChecklistItemCB, event) => {
  let title = ReactEvent.Form.target(event)##value;
  let newChecklistItem = checklistItem |> ChecklistItem.updateTitle(title);
  updateChecklistItemCB(newChecklistItem);
};

let updateKind = (checklistItem, updateChecklistItemCB, kind) => {
  let newChecklistItem = checklistItem |> ChecklistItem.updateKind(kind);
  updateChecklistItemCB(newChecklistItem);
};

let updateOptional = (checklistItem, updateChecklistItemCB, event) => {
  let optional = ReactEvent.Form.target(event)##checked;
  let newChecklistItem =
    checklistItem |> ChecklistItem.updateOptional(optional);
  updateChecklistItemCB(newChecklistItem);
};

let checklistDropdown = (checklistItem, updateChecklistItemCB) => {
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
    [|
      ChecklistItem.LongText,
      ShortText,
      Files,
      Link,
      MultiChoice([||]),
      Statement,
    |]
    |> Js.Array.filter(kind => kind != selectedKind)
    |> Array.mapi((index, kind) =>
         <button
           key={index |> string_of_int}
           onClick={_ =>
             updateKind(checklistItem, updateChecklistItemCB, kind)
           }>
           {kind |> ChecklistItem.actionStringForKind |> str}
         </button>
       );
  <Dropdown selected contents />;
};

let removeMultichoiceOption =
    (choiceIndex, checklistItem, updateChecklistItemCB) => {
  let newChecklistItem =
    checklistItem |> ChecklistItem.removeMultichoiceOption(choiceIndex);
  updateChecklistItemCB(newChecklistItem);
};
let addMultichoiceOption = (checklistItem, updateChecklistItemCB) => {
  let newChecklistItem = checklistItem |> ChecklistItem.addMultichoiceOption;
  updateChecklistItemCB(newChecklistItem);
};

let multiChoiceEditor =
    (choices, checklistItem, removeMultichoiceOption, updateChecklistItemCB) => {
  <div className="ml-3 mt-3">
    <div className="text-xs font-semibold mb-2"> {"Choices:" |> str} </div>
    {let showRemoveIcon = Array.length(choices) > 2;
     choices
     |> Array.mapi((index, choice) =>
          <div
            key={index |> string_of_int}
            className="flex items-center text-sm rounded mb-2">
            <span className="text-gray-400">
              <i className="far fa-circle text-base" />
            </span>
            <div
              className="flex flex-1 py-2 px-3 ml-6 justify-between items-center focus:outline-none bg-white focus:bg-white focus:border-primary-300 border border-gray-400 rounded">
              <input
                className="flex-1 appearance-none bg-transparent border-none leading-snug focus:outline-none"
                type_="text"
                value=choice
              />
              <button
                onClick={_ =>
                  removeMultichoiceOption(
                    index,
                    checklistItem,
                    updateChecklistItemCB,
                  )
                }>
                {showRemoveIcon
                   ? <PfIcon className="if i-times-light if-fw" /> : React.null}
              </button>
            </div>
          </div>
        )
     |> React.array}
    <button
      onClick={_ =>
        addMultichoiceOption(checklistItem, updateChecklistItemCB)
      }
      className="flex ml-10 p-2 text-sm appearance-none bg-white border items-center justify-between outline-none border border-gray-400 hover:border-gray-100 hover:shadow-lg">
      <PfIcon className="if i-plus-circle if-fw" />
      <span className="font-semibold ml-2"> {"Add a choice" |> str} </span>
    </button>
  </div>;
};

[@react.component]
let make = (~checklistItem, ~index, ~updateChecklistItemCB) => {
  <div className="mt-2">
    {<div
       className="flex-col bg-gray-100 mb-2 p-2" key={index |> string_of_int}>
       <div className="flex justify-between items-center">
         <div className="ml-2 flex justify-start items-center">
           <span className="font-semibold text-sm mr-2">
             {(index + 1 |> string_of_int) ++ "." |> str}
           </span>
           {checklistDropdown(checklistItem, updateChecklistItemCB)}
         </div>
         <div className="items-center">
           <input
             className="leading-tight"
             type_="checkbox"
             onChange={updateOptional(checklistItem, updateChecklistItemCB)}
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
           className="flex-grow appearance-none bg-transparent border-none leading-snug focus:outline-none"
           placeholder="Describe this step"
           onChange={updateTitle(checklistItem, updateChecklistItemCB)}
           type_="text"
           value={checklistItem |> ChecklistItem.title}
         />
       </div>
       {switch (checklistItem |> ChecklistItem.kind) {
        | MultiChoice(choices) =>
          multiChoiceEditor(
            choices,
            checklistItem,
            removeMultichoiceOption,
            updateChecklistItemCB,
          )
        | ShortText
        | LongText
        | Files
        | Link
        | Statement => React.null
        }}
     </div>}
  </div>;
};
