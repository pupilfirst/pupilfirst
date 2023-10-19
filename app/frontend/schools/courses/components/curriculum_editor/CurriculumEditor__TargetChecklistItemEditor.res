open CurriculumEditor__Types

let str = React.string

let t = I18n.t(~scope="components.CurriculumEditor__TargetChecklistItemEditor")
let ts = I18n.ts

let updateTitle = (checklistItem, updateChecklistItemCB, title) => {
  let newChecklistItem = checklistItem |> ChecklistItem.updateTitle(title)
  updateChecklistItemCB(newChecklistItem)
}

let updateKind = (checklistItem, updateChecklistItemCB, kind) => {
  let newChecklistItem = checklistItem |> ChecklistItem.updateKind(kind)
  updateChecklistItemCB(newChecklistItem)
}

let updateOptional = (checklistItem, updateChecklistItemCB, event) => {
  let optional = ReactEvent.Form.target(event)["checked"]
  let newChecklistItem = checklistItem |> ChecklistItem.updateOptional(optional)
  updateChecklistItemCB(newChecklistItem)
}

let selectedButtonIcon = kind =>
  switch kind {
  | ChecklistItem.LongText => "i-long-text-regular rlt:rotate-180"
  | ShortText => "i-short-text-regular"
  | Files => "i-file-regular"
  | Link => "i-link-regular"
  | AudioRecord => "i-microphone-outline-regular"
  | MultiChoice(_choices, _allowMultiple) => "i-check-circle-alt-regular"
  }
let checklistDropdown = (checklistItem, updateChecklistItemCB) => {
  let selectedKind = checklistItem |> ChecklistItem.kind
  let selectedButtonColor = switch selectedKind {
  | LongText => "border-blue-500 bg-blue-100 text-blue-800"
  | ShortText => "border-orange-500 bg-orange-100 text-orange-800"
  | Files => "border-yellow-500 bg-yellow-100 text-yellow-800"
  | Link => "border-focusColor-500 bg-focusColor-100 text-focusColor-800"
  | AudioRecord => "border-red-500 bg-red-100 text-red-800"
  | MultiChoice(_choices, _allowMultiple) => "border-green-500 bg-green-100 text-green-800"
  }
  let selectedIconColor =
    "text-white " ++
    switch selectedKind {
    | LongText => "bg-blue-500"
    | ShortText => "bg-orange-500"
    | Files => "bg-yellow-500"
    | Link => "bg-focusColor-500"
    | AudioRecord => "bg-red-500"
    | MultiChoice(_choices, _allowMultiple) => "bg-green-500"
    }
  let selected =
    <button
      className={"border focus:outline-none appearance-none flex items-center rounded focus:ring focus:ring-focusColor-500 " ++
      selectedButtonColor}>
      <div className="flex">
        <span
          className={"flex items-center justify-center rounded text-white p-1 m-1 " ++
          selectedIconColor}>
          <PfIcon className={"if if-fw " ++ selectedButtonIcon(selectedKind)} />
        </span>
        <span className="inline-flex items-center px-1 py-1 font-semibold text-xs">
          {selectedKind |> ChecklistItem.actionStringForKind |> str}
        </span>
      </div>
      <span className="px-2 py-1 flex items-center">
        <i className="fas fa-caret-down text-xs" />
      </span>
    </button>

  let kindTypes = [
    ChecklistItem.LongText,
    ShortText,
    Link,
    MultiChoice([ts("_yes"), ts("_no")], false),
    AudioRecord,
    Files,
  ]

  let contents =
    kindTypes
    |> Js.Array.filter(kind => kind != selectedKind)
    |> Js.Array.mapi((kind, index) =>
      <button
        key={index |> string_of_int}
        className="w-full px-2 py-1 focus:outline-none appearance-none "
        onClick={_ => updateKind(checklistItem, updateChecklistItemCB, kind)}>
        <PfIcon className={"me-2 if if-fw " ++ selectedButtonIcon(kind)} />
        {kind |> ChecklistItem.actionStringForKind |> str}
      </button>
    )
  <Dropdown selected contents />
}

let removeMultichoiceOption = (choiceIndex, checklistItem, updateChecklistItemCB) => {
  let newChecklistItem = checklistItem |> ChecklistItem.removeMultichoiceOption(choiceIndex)
  updateChecklistItemCB(newChecklistItem)
}
let addMultichoiceOption = (checklistItem, updateChecklistItemCB) => {
  let newChecklistItem = checklistItem |> ChecklistItem.addMultichoiceOption
  updateChecklistItemCB(newChecklistItem)
}

let updateChoiceText = (choiceIndex, checklistItem, updateChecklistItemCB, event) => {
  let choice = ReactEvent.Form.target(event)["value"]
  let newChecklistItem = checklistItem |> ChecklistItem.updateMultichoiceOption(choiceIndex, choice)
  updateChecklistItemCB(newChecklistItem)
}

let updateAllowMultiple = (checklistItem, updateChecklistItemCB, event) => {
  let allowMultiple = ReactEvent.Form.target(event)["checked"]
  let newChecklistItem = checklistItem |> ChecklistItem.updateAllowMultiple(allowMultiple)
  updateChecklistItemCB(newChecklistItem)
}

let multiChoiceEditor = (
  index,
  choices,
  allowMultiple,
  checklistItem,
  removeMultichoiceOption,
  updateChecklistItemCB,
) => {
  <div className="ms-3 mt-3">
    <div className="flex items-center">
      <input
        className="leading-tight"
        type_="checkbox"
        id={index->string_of_int ++ "-allow-multiple"}
        checked={allowMultiple}
        onChange={updateAllowMultiple(checklistItem, updateChecklistItemCB)}
      />
      <label
        className="text-xs text-gray-600 ms-2" htmlFor={index->string_of_int ++ "-allow-multiple"}>
        {t("multi_choice") |> str}
      </label>
    </div>
    <div className="text-xs font-semibold pb-2 pt-4"> {t("choices") ++ ":" |> str} </div>
    {
      let showRemoveIcon = Js.Array.length(choices) > 2
      choices
      |> Js.Array.mapi((choice, index) =>
        <div key={index |> string_of_int}>
          <div className="flex items-center text-sm rounded mt-2">
            {
              let shape = allowMultiple ? "square" : "circle"
              <span className="text-gray-400">
                <PfIcon className={`if i-${shape}-light if-fw`} />
              </span>
            }
            <div
              className="flex flex-1 py-2 px-3 ms-3 justify-between items-center focus:outline-none bg-white focus-within:bg-white focus-within:border-transparent focus-within:ring-2 focus:ring-focusColor-500 border border-gray-300 rounded">
              <input
                name={"multichoice-input-" ++ (index + 1 |> string_of_int)}
                className="flex-1 appearance-none bg-transparent border-none leading-snug focus:outline-none"
                onChange={updateChoiceText(index, checklistItem, updateChecklistItemCB)}
                type_="text"
                value=choice
              />
              <button
                className="flex items-center hover:text-red-500 focus:text-red-500"
                title={t("remove_choice") ++ " " ++ (index + 1 |> string_of_int)}
                ariaLabel={t("remove_choice") ++ " " ++ (index + 1 |> string_of_int)}
                onClick={_ => removeMultichoiceOption(index, checklistItem, updateChecklistItemCB)}>
                {showRemoveIcon ? <PfIcon className="if i-times-regular if-fw" /> : React.null}
              </button>
            </div>
          </div>
          <div className="ms-6">
            <School__InputGroupError
              message={t("not_valid_choice")} active={choice |> String.trim == ""}
            />
          </div>
        </div>
      )
      |> React.array
    }
    <div>
      <School__InputGroupError
        message={t("choices_not_unique")}
        active={ArrayUtils.distinct(choices)->Js.Array.length != Js.Array2.length(choices)}
      />
    </div>
    <button
      onClick={_ => addMultichoiceOption(checklistItem, updateChecklistItemCB)}
      className="flex mt-2 ms-7 p-2 text-sm appearance-none bg-white border rounded items-center justify-between outline-none border-gray-300 hover:border-gray-100 hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-focusColor-500">
      <PfIcon className="fas fa-plus-circle if-fw" />
      <span className="font-semibold ms-2"> {t("add_choice") |> str} </span>
    </button>
  </div>
}

let controlIcon = (~icon, ~title, ~handler) =>
  handler == None
    ? React.null
    : <button
        title
        ariaLabel={title}
        disabled={handler == None}
        className="px-2 py-1 focus:outline-none text-sm text-gray-600 hover:bg-gray-300 hover:text-gray-900 focus:bg-gray-300 focus:text-gray-900 overflow-hidden"
        onClick=?handler>
        <i className={"fas fa-fw " ++ icon} />
      </button>

let filesNotice =
  <div className="mt-2 text-sm">
    <strong> {I18n.t("shared.note") |> str} </strong>
    <span className="ms-1"> {t("limits_notice") |> str} </span>
  </div>

let isRequiredStepTitleDuplicated = (checklist, item) => {
  let trimmedTitle = item |> ChecklistItem.title |> String.trim

  if trimmedTitle == "" {
    false
  } else {
    checklist
    |> Js.Array.filter(item => !ChecklistItem.optional(item))
    |> Js.Array.filter(checklistItem =>
      checklistItem |> ChecklistItem.title |> String.trim == trimmedTitle
    )
    |> Js.Array.length > 1
  }
}

@react.component
let make = (
  ~checklist,
  ~checklistItem,
  ~index,
  ~updateChecklistItemCB,
  ~removeChecklistItemCB,
  ~moveChecklistItemUpCB=?,
  ~moveChecklistItemDownCB=?,
  ~copyChecklistItemCB,
) => {
  <div
    key={index |> string_of_int}
    ariaLabel={t("editor_checklist") ++ " " ++ (index + 1 |> string_of_int)}
    className="flex items-start py-2 relative">
    <div className="w-full bg-gray-50 border rounded-lg p-5 me-1">
      <div className="flex justify-between items-center">
        <div> {checklistDropdown(checklistItem, updateChecklistItemCB)} </div>
        <div className="items-center">
          <input
            className="leading-tight"
            type_="checkbox"
            onChange={updateOptional(checklistItem, updateChecklistItemCB)}
            id={index |> string_of_int}
            checked={checklistItem |> ChecklistItem.optional}
          />
          <label className="text-xs text-gray-600 ms-2" htmlFor={index |> string_of_int}>
            {t("optional") |> str}
          </label>
        </div>
      </div>
      <div className="py-2 mt-2 ">
        <MarkdownEditor
          textareaId={"checklist-item-" ++ (string_of_int(index + 1) ++ "-title")}
          placeholder={t("describe_question")}
          value={checklistItem->ChecklistItem.title}
          onChange={updateTitle(checklistItem, updateChecklistItemCB)}
          profile=Markdown.Permissive
        />
      </div>
      <div>
        <School__InputGroupError
          message={t("question_cannot_empty")}
          active={checklistItem |> ChecklistItem.title |> String.trim == ""}
        />
        <School__InputGroupError
          message={t("not_unique_question")}
          active={isRequiredStepTitleDuplicated(checklist, checklistItem)}
        />
      </div>
      {switch checklistItem |> ChecklistItem.kind {
      | MultiChoice(choices, allowMultiple) =>
        multiChoiceEditor(
          index,
          choices,
          allowMultiple,
          checklistItem,
          removeMultichoiceOption,
          updateChecklistItemCB,
        )
      | Files => filesNotice
      | ShortText
      | LongText
      | AudioRecord
      | Link => React.null
      }}
    </div>
    <div
      ariaLabel={t("controls_checklist") ++ " " ++ (index + 1 |> string_of_int)}
      className="--me-10 shrink-0 border bg-gray-50 rounded-lg flex flex-col text-xs sticky top-0">
      {controlIcon(
        ~icon="fa-arrow-up",
        ~title=t("move_up"),
        ~handler=moveChecklistItemUpCB |> OptionUtils.map((cb, _) => cb()),
      )}
      {controlIcon(
        ~icon="fa-arrow-down",
        ~title=t("move_down"),
        ~handler=moveChecklistItemDownCB |> OptionUtils.map((cb, _) => cb()),
      )}
      {controlIcon(~icon="fa-copy", ~title=t("copy"), ~handler=Some(_ => copyChecklistItemCB()))}
      {controlIcon(
        ~icon="fa-trash-alt",
        ~title=t("delete"),
        ~handler=Some(_ => removeChecklistItemCB()),
      )}
    </div>
  </div>
}
