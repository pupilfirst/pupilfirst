open CoursesReview__Types

type selectionItem = {
  itemIndex: int,
  resultIndex: int,
}

let str = React.string

let t = I18n.t(~scope="components.CoursesReview__ChecklistShow")

let selectChecklist = (itemIndex, resultIndex, setSelecton) =>
  setSelecton(selection =>
    selection |> Array.append([{itemIndex: itemIndex, resultIndex: resultIndex}])
  )

let unSelectChecklist = (itemIndex, resultIndex, setSelecton) =>
  setSelecton(selection =>
    selection |> Js.Array.filter(item =>
      !(item.itemIndex == itemIndex && item.resultIndex == resultIndex)
    )
  )

let checkboxOnChange = (itemIndex, resultIndex, setSelecton, event) =>
  ReactEvent.Form.target(event)["checked"]
    ? selectChecklist(itemIndex, resultIndex, setSelecton)
    : unSelectChecklist(itemIndex, resultIndex, setSelecton)

let generateFeedback = (reviewChecklist, selection, feedback, setSelecton, updateFeedbackCB) => {
  let newFeedback =
    feedback ++ ("\n\n" ++ (reviewChecklist |> Array.mapi((i, reviewChecklistItem) => {
      let resultIndexList =
        selection
        |> Js.Array.filter(selectionItem => selectionItem.itemIndex == i)
        |> Array.map(item => item.resultIndex)

      reviewChecklistItem |> ReviewChecklistItem.result |> Array.mapi((index, resultItem) =>
        resultIndexList |> Array.mem(index)
          ? switch resultItem |> ReviewChecklistResult.feedback {
            | Some(feedback) => list{feedback}
            | None => list{}
            }
          : list{}
      ) |> Array.to_list |> List.flatten
    }) |> Array.to_list |> List.flatten |> Array.of_list |> Js.Array.joinWith("\n\n")))
  setSelecton(_ => [])
  updateFeedbackCB(newFeedback)
}
let checklistItemCheckedClasses = (itemIndex, selection) =>
  "mb-4 px-2 pb-2 md:px-4 border-l-2 border-transparent " ++ (
    selection |> Js.Array.filter(s => s.itemIndex == itemIndex) |> ArrayUtils.isNotEmpty
      ? "border-green-400"
      : ""
  )

let checklistItemChecked = (itemIndex, resultIndex, selection) =>
  selection
  |> Js.Array.filter(s => s.itemIndex == itemIndex && s.resultIndex == resultIndex)
  |> ArrayUtils.isNotEmpty

@react.component
let make = (~reviewChecklist, ~feedback, ~updateFeedbackCB, ~showEditorCB) => {
  let (selection, setSelecton) = React.useState(() => [])
  let (id, _setId) = React.useState(() => DateTime.randomId() ++ "-review-checkbox-")

  <div className="relative border bg-gray-100 rounded-lg py-2 md:py-4">
    <div className="absolute right-0 top-0 -mt-9">
      <button
        className="flex items-center btn btn-small btn-primary-ghost" onClick={_ => showEditorCB()}>
        <i className="far fa-edit" />
        <span className="ml-2 leading-tight"> {t("edit_checklist_button") |> str} </span>
      </button>
    </div>
    {reviewChecklist
    |> Array.mapi((itemIndex, reviewChecklistItem) =>
      <div
        className={checklistItemCheckedClasses(itemIndex, selection)}
        key={itemIndex |> string_of_int}
        ariaLabel={"checklist-item-" ++ (itemIndex |> string_of_int)}>
        <h4 className="text-base font-semibold mt-2 md:mt-0 w-full md:w-4/5">
          {reviewChecklistItem |> ReviewChecklistItem.title |> str}
        </h4>
        <div>
          {reviewChecklistItem
          |> ReviewChecklistItem.result
          |> Array.mapi((resultIndex, checklistItem) =>
            <div
              className="px-2 md:px-4 mt-2"
              ariaLabel={"result-item-" ++ (resultIndex |> string_of_int)}
              key={(itemIndex |> string_of_int) ++ (resultIndex |> string_of_int)}>
              <Checkbox
                id={id ++ ((itemIndex |> string_of_int) ++ (resultIndex |> string_of_int))}
                label={str(checklistItem->ReviewChecklistResult.title)}
                onChange={checkboxOnChange(itemIndex, resultIndex, setSelecton)}
                checked={checklistItemChecked(itemIndex, resultIndex, selection)}
              />
              <div className="pl-7">
                <CoursesReview__ChecklistShowFeedback
                  feedback={checklistItem |> ReviewChecklistResult.feedback}
                />
              </div>
            </div>
          )
          |> React.array}
        </div>
      </div>
    )
    |> React.array}
    <div className="text-center max-w-xs mx-2 md:mx-auto">
      <button
        className="btn btn-primary btn-large w-full "
        disabled={selection |> ArrayUtils.isEmpty}
        onClick={_ =>
          generateFeedback(reviewChecklist, selection, feedback, setSelecton, updateFeedbackCB)}>
        {t("generate_feedback_button") |> str}
      </button>
    </div>
  </div>
}
