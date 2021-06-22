open CoursesReview__Types

type selectionItem = {
  itemIndex: int,
  resultIndex: int,
}

let str = React.string

let t = I18n.t(~scope="components.CoursesReview__ChecklistShow")

let selectChecklist = (itemIndex, resultIndex, setSelecton) =>
  setSelecton(selection =>
    Js.Array.concat(selection, [{itemIndex: itemIndex, resultIndex: resultIndex}])
  )

let unSelectChecklist = (itemIndex, resultIndex, setSelecton) =>
  setSelecton(selection =>
    Js.Array.filter(
      item => !(item.itemIndex == itemIndex && item.resultIndex == resultIndex),
      selection,
    )
  )

let checkboxOnChange = (itemIndex, resultIndex, setSelecton, event) =>
  ReactEvent.Form.target(event)["checked"]
    ? selectChecklist(itemIndex, resultIndex, setSelecton)
    : unSelectChecklist(itemIndex, resultIndex, setSelecton)

let generateFeedback = (checklist, selection, feedback, setSelecton, updateFeedbackCB) => {
  // Todo: Convert to array and use array flatten
  let newFeedback = feedback ++ ("\n\n" ++ (checklist |> Array.mapi((i, reviewChecklistItem) => {
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
    Js.Array.filter(s => s.itemIndex == itemIndex, selection)->ArrayUtils.isNotEmpty
      ? "border-green-400"
      : ""
  )

let checklistItemChecked = (itemIndex, resultIndex, selection) =>
  Js.Array.filter(
    s => s.itemIndex == itemIndex && s.resultIndex == resultIndex,
    selection,
  )->ArrayUtils.isNotEmpty

let updateChecklistResultFeedback = (
  itemIndex,
  resultIndex,
  feedback,
  reviewChecklistItem,
  resultItem,
  setChecklist,
) => {
  let newReviewChecklistItem = ReviewChecklistItem.updateChecklist(
    ReviewChecklistResult.updateFeedback(
      feedback,
      resultItem,
      resultIndex,
      ReviewChecklistItem.result(reviewChecklistItem),
    ),
    reviewChecklistItem,
  )

  setChecklist(checklist =>
    ReviewChecklistItem.replace(newReviewChecklistItem, itemIndex, checklist)
  )
}

@react.component
let make = (~reviewChecklist, ~feedback, ~updateFeedbackCB, ~showEditorCB) => {
  let (checklist, setChecklist) = React.useState(() => reviewChecklist)
  let (selection, setSelecton) = React.useState(() => [])
  let (id, _setId) = React.useState(() => DateTime.randomId() ++ "-review-checkbox-")

  <div className="relative border bg-gray-100 rounded-lg py-2 md:py-4">
    <div className="absolute right-0 top-0 -mt-9">
      <button
        className="flex items-center btn btn-small btn-primary-ghost" onClick={_ => showEditorCB()}>
        <i className="far fa-edit" />
        <span className="ml-2 leading-tight"> {t("edit_checklist_button")->str} </span>
      </button>
    </div>
    {Js.Array.mapi(
      (reviewChecklistItem, itemIndex) =>
        <div
          className={checklistItemCheckedClasses(itemIndex, selection)}
          key={string_of_int(itemIndex)}
          ariaLabel={"checklist-item-" ++ itemIndex->string_of_int}>
          <h4 className="text-base font-semibold mt-2 md:mt-0 w-full md:w-4/5">
            {ReviewChecklistItem.title(reviewChecklistItem)->str}
          </h4>
          <div> {Js.Array.mapi((checklistItem, resultIndex) =>
              <div
                className="px-2 md:px-4 mt-2"
                ariaLabel={"result-item-" ++ resultIndex->string_of_int}
                key={itemIndex->string_of_int ++ resultIndex->string_of_int}>
                <Checkbox
                  id={id ++ (itemIndex->string_of_int ++ resultIndex->string_of_int)}
                  label={str(checklistItem->ReviewChecklistResult.title)}
                  onChange={checkboxOnChange(itemIndex, resultIndex, setSelecton)}
                  checked={checklistItemChecked(itemIndex, resultIndex, selection)}
                />
                {
                  let isSelected =
                    Js.Array.find(
                      s => s.itemIndex == itemIndex && s.resultIndex == resultIndex,
                      selection,
                    )->Belt.Option.isSome

                  ReactUtils.nullUnless(
                    <div className="pl-7">
                      <textarea
                        rows=2
                        cols=33
                        className="appearance-none border border-gray-400 bg-transparent rounded-b text-xs align-top py-2 px-4 leading-relaxed w-full focus:outline-none focus:bg-white focus:border-primary-300"
                        id={"result_" ++ (resultIndex->string_of_int ++ "_feedback")}
                        type_="text"
                        placeholder="Add feedback (optional)"
                        value={Belt.Option.getWithDefault(
                          ReviewChecklistResult.feedback(checklistItem),
                          "",
                        )}
                        onChange={event =>
                          updateChecklistResultFeedback(
                            itemIndex,
                            resultIndex,
                            ReactEvent.Form.target(event)["value"],
                            reviewChecklistItem,
                            checklistItem,
                            setChecklist,
                          )}
                      />
                    </div>,
                    isSelected,
                  )
                }
              </div>
            , ReviewChecklistItem.result(reviewChecklistItem))->React.array} </div>
        </div>,
      checklist,
    )->React.array}
    <div className="text-center max-w-xs mx-2 md:mx-auto">
      <button
        className="btn btn-primary btn-large w-full "
        disabled={selection->ArrayUtils.isEmpty}
        onClick={_ =>
          generateFeedback(checklist, selection, feedback, setSelecton, updateFeedbackCB)}>
        {t("generate_feedback_button")->str}
      </button>
    </div>
  </div>
}
