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

let buttonColorClasses = color => {
  "border-"
  ++ color
  ++ "-500 "
  ++ "bg-"
  ++ color
  ++ "-100 "
  ++ "text-"
  ++ color
  ++ "-800";
};
let selectedButtonIcon = kind =>
  switch (kind) {
  | ChecklistItem.LongText => "i-long-text-regular"
  | ShortText => "i-short-text-regular"
  | Files => "i-file-regular"
  | Link => "i-link-regular"
  | MultiChoice(_choices) => "i-check-circle-alt-regular"
  };
let checklistDropdown = (checklistItem, updateChecklistItemCB) => {
  let selectedKind = checklistItem |> ChecklistItem.kind;
  let selectedButtonColor =
    switch (selectedKind) {
    | LongText => "blue"
    | ShortText => "orange"
    | Files => "green"
    | Link => "purple"
    | MultiChoice(_choices) => "pink"
    };
  let selected =
    <button
      className={
        "border focus:outline-none appearance-none inline-flex items-center rounded "
        ++ buttonColorClasses(selectedButtonColor)
      }>
      <span className="px-2 py-2">
        <PfIcon
          className={"mr-2 if if-fw " ++ selectedButtonIcon(selectedKind)}
        />
        {selectedKind |> ChecklistItem.actionStringForKind |> str}
      </span>
      <span className="px-2 py-2">
        <i className="fas fa-chevron-down text-sm" />
      </span>
    </button>;

  let contents =
    [|ChecklistItem.LongText, ShortText, Files, Link, MultiChoice([||])|]
    |> Js.Array.filter(kind => kind != selectedKind)
    |> Array.mapi((index, kind) =>
         <button
           key={index |> string_of_int}
           className="w-full px-2 py-1 focus:outline-none appearance-none text-left"
           onClick={_ =>
             updateKind(checklistItem, updateChecklistItemCB, kind)
           }>
           <PfIcon className={"mr-2 if if-fw " ++ selectedButtonIcon(kind)} />
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

let updateChoiceText =
    (choiceIndex, checklistItem, updateChecklistItemCB, event) => {
  let choice = ReactEvent.Form.target(event)##value;
  let newChecklistItem =
    checklistItem
    |> ChecklistItem.updateMultichoiceOption(choiceIndex, choice);
  updateChecklistItemCB(newChecklistItem);
};

let multiChoiceEditor =
    (choices, checklistItem, removeMultichoiceOption, updateChecklistItemCB) => {
  <div className="ml-3 mt-3">
    <div className="text-xs font-semibold mb-2"> {"Choices:" |> str} </div>
    {let showRemoveIcon = Array.length(choices) > 2;
     choices
     |> Array.mapi((index, choice) =>
          <div>
            <div
              key={index |> string_of_int}
              className="flex items-center text-sm rounded mt-2">
              <span className="text-gray-400">
                <i className="far fa-circle text-base" />
              </span>
              <div
                className="flex flex-1 py-2 px-3 ml-3 justify-between items-center focus:outline-none bg-white focus:bg-white focus:border-primary-300 border border-gray-400 rounded">
                <input
                  className="flex-1 appearance-none bg-transparent border-none leading-snug focus:outline-none"
                  onChange={updateChoiceText(
                    index,
                    checklistItem,
                    updateChecklistItemCB,
                  )}
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
                     ? <PfIcon className="if i-times-light if-fw" />
                     : React.null}
                </button>
              </div>
            </div>
            <div className="ml-6">
              <School__InputGroupError
                message="Not a valid choice"
                active={choice |> String.trim == ""}
              />
            </div>
          </div>
        )
     |> React.array}
    <button
      onClick={_ =>
        addMultichoiceOption(checklistItem, updateChecklistItemCB)
      }
      className="flex mt-2 ml-7 p-2 text-sm appearance-none bg-white border items-center justify-between outline-none border border-gray-400 hover:border-gray-100 hover:shadow-lg focus:outline-none">
      <PfIcon className="if i-plus-circle if-fw" />
      <span className="font-semibold ml-2"> {"Add a choice" |> str} </span>
    </button>
  </div>;
};

let controlIcon = (~icon, ~title, ~handler) => {
  handler == None
    ? React.null
    : <button
        title
        disabled={handler == None}
        className="p-2 focus:outline-none"
        onClick=?handler>
        <i className={"fas fa-fw " ++ icon} />
      </button>;
};

let onDelete = (cb, _event) => {
  WindowUtils.confirm("Are you sure you want to delete this item?", () => {
    cb()
  });
};

let onMove = (cb, _event) => {
  cb();
};

let onCopy = (cb, _event) => {
  cb();
};

[@react.component]
let make =
    (
      ~checklistItem,
      ~index,
      ~updateChecklistItemCB,
      ~removeChecklistItemCB,
      ~moveChecklistItemUpCB=?,
      ~moveChecklistItemDownCB=?,
      ~copyChecklistItemCB,
    ) => {
  <div className="flex items-start mt-2">
    <div
      className="flex-1 bg-gray-100 mb-2 px-2 py-3"
      key={index |> string_of_int}>
      <div className="flex justify-between items-center">
        <div className="ml-3">
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
      <div className="ml-3">
        <School__InputGroupError
          message="Not a valid title"
          active={checklistItem |> ChecklistItem.title |> String.trim == ""}
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
       | Link => React.null
       }}
    </div>
    <div
      className="ml-2 flex-shrink-0 border-transparent bg-gray-100 border rounded flex flex-col text-xs">
      {controlIcon(
         ~icon="fa-arrow-up",
         ~title="Move Up",
         ~handler=moveChecklistItemUpCB |> OptionUtils.map(cb => onMove(cb)),
       )}
      {controlIcon(
         ~icon="fa-arrow-down",
         ~title="Move Down",
         ~handler=
           moveChecklistItemDownCB |> OptionUtils.map(cb => onMove(cb)),
       )}
      {controlIcon(
         ~icon="fa-copy",
         ~title="Copy",
         ~handler=Some(onCopy(copyChecklistItemCB)),
       )}
      {controlIcon(
         ~icon="fa-trash-alt",
         ~title="Delete",
         ~handler=Some(onDelete(removeChecklistItemCB)),
       )}
    </div>
  </div>;
};
