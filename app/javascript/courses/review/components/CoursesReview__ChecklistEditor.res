%raw(`require("./CoursesReview__ChecklistEditor.css")`)

let t = I18n.t(~scope="components.CoursesReview__ChecklistEditor")

open CoursesReview__Types

type state = {
  reviewChecklist: array<ReviewChecklistItem.t>,
  saving: bool,
}

let str = React.string

module UpdateReviewChecklistMutation = %graphql(`
    mutation UpdateReviewChecklistMutation($targetId: ID!, $reviewChecklist: JSON!) {
      updateReviewChecklist(targetId: $targetId, reviewChecklist: $reviewChecklist){
        success
      }
    }
  `)

let updateReviewChecklist = (targetId, reviewChecklist, setState, updateReviewChecklistCB) => {
  setState(state => {...state, saving: true})

  let trimmedChecklist = reviewChecklist->Js.Array2.map(ReviewChecklistItem.trim)

  UpdateReviewChecklistMutation.make(
    ~targetId,
    ~reviewChecklist=ReviewChecklistItem.encodeArray(trimmedChecklist),
    (),
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    if response["updateReviewChecklist"]["success"] {
      updateReviewChecklistCB(trimmedChecklist)
    }

    setState(state => {...state, saving: false})
    Js.Promise.resolve()
  })
  |> ignore
}

let updateChecklistItem = (checklistItem, itemIndex, setState) =>
  setState(state => {
    ...state,
    reviewChecklist: ReviewChecklistItem.replace(checklistItem, itemIndex, state.reviewChecklist),
  })

let updateChecklistItemTitle = (itemIndex, title, checklistItem, setState) =>
  updateChecklistItem(ReviewChecklistItem.updateTitle(title, checklistItem), itemIndex, setState)

let moveChecklistItemUp = (itemIndex, setState) => {
  itemIndex > 0
    ? Some(
        () =>
          setState(state => {
            ...state,
            reviewChecklist: state.reviewChecklist |> ReviewChecklistItem.moveUp(itemIndex),
          }),
      )
    : None
}

let moveChecklistItemDown = (itemIndex, setState, state) => {
  itemIndex != Js.Array.length(state.reviewChecklist) - 1
    ? Some(
        () =>
          setState(state => {
            ...state,
            reviewChecklist: state.reviewChecklist |> ReviewChecklistItem.moveDown(itemIndex),
          }),
      )
    : None
}

let updateChecklistResultTitle = (
  itemIndex,
  resultIndex,
  title,
  reviewChecklistItem,
  resultItem,
  setState,
) => {
  let newReviewChecklistItem = ReviewChecklistItem.updateChecklist(
    ReviewChecklistResult.updateTitle(
      title,
      resultItem,
      resultIndex,
      ReviewChecklistItem.result(reviewChecklistItem),
    ),
    reviewChecklistItem,
  )
  updateChecklistItem(newReviewChecklistItem, itemIndex, setState)
}

let updateChecklistResultFeedback = (
  itemIndex,
  resultIndex,
  feedback,
  reviewChecklistItem,
  resultItem,
  setState,
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
  updateChecklistItem(newReviewChecklistItem, itemIndex, setState)
}

let addEmptyResultItem = (reviewChecklistItem, itemIndex, setState) =>
  updateChecklistItem(
    ReviewChecklistItem.appendEmptyChecklistItem(reviewChecklistItem),
    itemIndex,
    setState,
  )

let addEmptyChecklistItem = setState =>
  setState(state => {
    ...state,
    reviewChecklist: Js.Array2.concat(state.reviewChecklist, ReviewChecklistItem.empty()),
  })

let removeChecklistResult = (itemIndex, resultIndex, reviewChecklistItem, setState) =>
  updateChecklistItem(
    ReviewChecklistItem.deleteResultItem(resultIndex, reviewChecklistItem),
    itemIndex,
    setState,
  )

let removeChecklistItem = (itemIndex, setState) =>
  setState(state => {
    ...state,
    reviewChecklist: state.reviewChecklist->Js.Array2.filteri((_el, i) => i != itemIndex),
  })

let initialStateForReviewChecklist = reviewChecklist =>
  ArrayUtils.isEmpty(reviewChecklist) ? ReviewChecklistItem.emptyTemplate() : reviewChecklist

let invalidTitle = title => title->Js.String2.trim == ""

let invalidChecklist = reviewChecklist =>
  reviewChecklist
  ->Js.Array2.map(reviewChecklistItem =>
    invalidTitle(ReviewChecklistItem.title(reviewChecklistItem)) ||
    ReviewChecklistItem.result(reviewChecklistItem)
    ->Js.Array2.filter(resultItem => invalidTitle(ReviewChecklistResult.title(resultItem)))
    ->ArrayUtils.isNotEmpty
  )
  ->Js.Array2.filter(valid => valid)
  ->ArrayUtils.isNotEmpty

let controlIcon = (~icon, ~title, ~handler) =>
  handler == None
    ? React.null
    : <button
        title
        disabled={handler == None}
        className="px-2 py-1 focus:outline-none text-sm text-gray-700 hover:bg-gray-300 hover:text-gray-900 overflow-hidden"
        onClick=?handler>
        <i className={"fas fa-fw " ++ icon} />
      </button>

@react.component
let make = (~reviewChecklist, ~updateReviewChecklistCB, ~closeEditModeCB, ~targetId) => {
  let (state, setState) = React.useState(() => {
    reviewChecklist: initialStateForReviewChecklist(reviewChecklist),
    saving: false,
  })
  <div>
    <div className="flex items-center px-4 md:px-6 py-3 bg-white border-b sticky top-0 z-50 h-16">
      <div className="flex flex-1 items-center justify-between">
        <h5 className="font-semibold flex items-center tracking-wide">
          {(
            ArrayUtils.isEmpty(reviewChecklist)
              ? t("create_review_checklist")
              : t("edit_review_checklist")
          )->str}
        </h5>
      </div>
    </div>
    <DisablingCover disabled=state.saving>
      <div className="p-4 md:p-6 relative">
        <div className="bg-gray-200 border border-primary-300 rounded-md p-2 pt-0 md:p-4 md:pt-0">
          {state.reviewChecklist
          ->Js.Array2.mapi((reviewChecklistItem, itemIndex) =>
            <Spread
              props={"data-checklist-item": string_of_int(itemIndex)}
              key={string_of_int(itemIndex)}>
              <div
                className="pt-5"
                key={itemIndex->string_of_int}
                ariaLabel={"checklist-item-" ++ itemIndex->string_of_int}>
                <div className="flex">
                  <div className="w-full">
                    <input
                      className="checklist-editor__checklist-item-title h-11 text-sm focus:outline-none focus:bg-white focus:border-primary-300"
                      id={"checklist_" ++ string_of_int(itemIndex) ++ "_title"}
                      type_="text"
                      placeholder={t("checklist_title.placeholder")}
                      value={ReviewChecklistItem.title(reviewChecklistItem)}
                      onChange={event =>
                        updateChecklistItemTitle(
                          itemIndex,
                          ReactEvent.Form.target(event)["value"],
                          reviewChecklistItem,
                          setState,
                        )}
                    />
                    <School__InputGroupError
                      message={t("checklist_title.error_message")}
                      active={invalidTitle(ReviewChecklistItem.title(reviewChecklistItem))}
                    />
                  </div>
                  <div
                    className="-mr-10 flex-shrink-0 border bg-gray-100 rounded-lg flex flex-col text-xs sticky top-0">
                    {controlIcon(
                      ~icon="fa-arrow-up",
                      ~title="Move Up",
                      ~handler=moveChecklistItemUp(itemIndex, setState) |> OptionUtils.map((
                        cb,
                        _,
                      ) => cb()),
                    )}
                    {controlIcon(
                      ~icon="fa-arrow-down",
                      ~title="Move Down",
                      ~handler=moveChecklistItemDown(
                        itemIndex,
                        setState,
                        state,
                      ) |> OptionUtils.map((cb, _) => cb()),
                    )}
                    {controlIcon(
                      ~icon="fa-trash-alt",
                      ~title="Delete",
                      ~handler=Some(_ => removeChecklistItem(itemIndex, setState)),
                    )}
                  </div>
                </div>
                <div>
                  {ReviewChecklistItem.result(reviewChecklistItem)
                  ->Js.Array2.mapi((resultItem, resultIndex) => {
                    let feedback = Belt.Option.getWithDefault(
                      ReviewChecklistResult.feedback(resultItem),
                      "",
                    )
                    <Spread
                      props={"data-result-item": string_of_int(resultIndex)}
                      key={string_of_int(itemIndex) ++ string_of_int(resultIndex)}>
                      <div className="pl-2 md:pl-4 mt-2">
                        <div className="flex">
                          <label
                            title={t("disabled")}
                            className="flex-shrink-0 rounded border border-gray-400 bg-gray-100 w-4 h-4 mr-2 mt-3 cursor-not-allowed"
                          />
                          <div className="w-full bg-gray-100 relative">
                            <div className="relative">
                              <input
                                className="checklist-editor__checklist-result-item-title h-10 pr-12 focus:outline-none focus:bg-white focus:border-primary-300"
                                id={"result_" ++
                                string_of_int(itemIndex) ++
                                string_of_int(resultIndex) ++ "_title"}
                                type_="text"
                                placeholder={t("checklist_item_title.placeholder")}
                                value={ReviewChecklistResult.title(resultItem)}
                                onChange={event =>
                                  updateChecklistResultTitle(
                                    itemIndex,
                                    resultIndex,
                                    ReactEvent.Form.target(event)["value"],
                                    reviewChecklistItem,
                                    resultItem,
                                    setState,
                                  )}
                              />
                              <div
                                className="flex w-10 h-10 absolute top-0 right-0 mr-1 items-center justify-center">
                                <button
                                  title={t("checklist_item_title.remove_button_title")}
                                  className="flex items-center justify-center bg-gray-100 w-7 h-7 mt-px text-sm text-gray-700 hover:text-red-600 hover:bg-red-100 rounded-full ml-2 border border-transparent text-center"
                                  onClick={_ =>
                                    removeChecklistResult(
                                      itemIndex,
                                      resultIndex,
                                      reviewChecklistItem,
                                      setState,
                                    )}>
                                  <Icon className="if i-times-regular" />
                                </button>
                              </div>
                            </div>
                            <textarea
                              rows=2
                              cols=33
                              className="appearance-none border border-gray-400 bg-transparent rounded-b text-sm align-top py-2 px-4 leading-relaxed w-full focus:outline-none focus:bg-white focus:border-primary-300"
                              id={"result_" ++
                              string_of_int(itemIndex) ++
                              string_of_int(resultIndex) ++ "_feedback"}
                              type_="text"
                              placeholder={t("checklist_item_description.placeholder")}
                              value=feedback
                              onChange={event =>
                                updateChecklistResultFeedback(
                                  itemIndex,
                                  resultIndex,
                                  ReactEvent.Form.target(event)["value"],
                                  reviewChecklistItem,
                                  resultItem,
                                  setState,
                                )}
                            />
                            <School__InputGroupError
                              message={t("checklist_item_description.error_message")}
                              active={invalidTitle(ReviewChecklistResult.title(resultItem))}
                            />
                          </div>
                        </div>
                      </div>
                    </Spread>
                  })
                  ->React.array}
                  <button
                    onClick={_ => addEmptyResultItem(reviewChecklistItem, itemIndex, setState)}
                    className="checklist-editor__add-result-btn ml-2 md:ml-4 mt-3 flex items-center focus:outline-none">
                    <span
                      title={t("add_result")}
                      className="checklist-editor__add-result-btn-check flex-shrink-0 rounded border border-gray-400 bg-gray-100 w-4 h-4 mr-2"
                    />
                    <span
                      className="checklist-editor__add-result-btn-text flex items-center text-sm font-semibold bg-gray-200 px-3 py-1 rounded border border-dashed border-gray-600">
                      <i className="fas fa-plus text-xs mr-2" /> {t("add_result")->str}
                    </span>
                  </button>
                </div>
              </div>
            </Spread>
          )
          ->React.array}
          <div className="pt-5">
            <button
              className="flex items-center text-sm font-semibold bg-gray-200 rounded border border-dashed border-gray-600 w-full hover:text-primary-500 hover:bg-white hover:border-primary-500 hover:shadow-md focus:outline-none"
              onClick={_ => addEmptyChecklistItem(setState)}>
              <span className="bg-gray-300 py-2 w-10"> <i className="fas fa-plus text-sm" /> </span>
              <span className="px-3 py-2"> {t("add_checklist_item")->str} </span>
            </button>
          </div>
        </div>
      </div>
      <div className="flex bg-gray-100 border-t flex-row-reverse sticky bottom-0 px-4 py-2 md:py-4">
        <button
          disabled={state.saving || invalidChecklist(state.reviewChecklist)}
          onClick={_ =>
            updateReviewChecklist(
              targetId,
              state.reviewChecklist,
              setState,
              updateReviewChecklistCB,
            )}
          className="btn btn-success">
          {t("save_checklist")->str}
        </button>
        <button className="btn btn-subtle mr-4" onClick={_ => closeEditModeCB()}>
          {t("cancel")->str}
        </button>
      </div>
    </DisablingCover>
  </div>
}
