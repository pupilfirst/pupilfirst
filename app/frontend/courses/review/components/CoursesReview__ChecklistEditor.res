%%raw(`import "./CoursesReview__ChecklistEditor.css"`)

let t = I18n.t(~scope="components.CoursesReview__ChecklistEditor")

open CoursesReview__Types

type state = {
  reviewChecklist: array<ReviewChecklistItem.t>,
  saving: bool,
}

type action =
  | SwapUpReviewChecklistItem(int)
  | SwapDownReviewChecklistItem(int)
  | UpdateChecklistItem(ReviewChecklistItem.t, int)
  | AddEmptyChecklistItem
  | RemoveChecklistItem(int)
  | UpdateSaving

let str = React.string

module UpdateReviewChecklistMutation = %graphql(`
    mutation UpdateReviewChecklistMutation($targetId: ID!, $reviewChecklist: JSON!) {
      updateReviewChecklist(targetId: $targetId, reviewChecklist: $reviewChecklist){
        success
      }
    }
  `)

let updateReviewChecklist = (targetId, reviewChecklist, send, updateReviewChecklistCB) => {
  send(UpdateSaving)

  let trimmedChecklist = reviewChecklist->Js.Array2.map(ReviewChecklistItem.trim)

  UpdateReviewChecklistMutation.fetch({
    targetId: targetId,
    reviewChecklist: ReviewChecklistItem.encodeArray(trimmedChecklist),
  })
  |> Js.Promise.then_((response: UpdateReviewChecklistMutation.t) => {
    if response.updateReviewChecklist.success {
      updateReviewChecklistCB(trimmedChecklist)
    }

    send(UpdateSaving)
    Js.Promise.resolve()
  })
  |> ignore
}

let updateChecklistItemTitle = (itemIndex, title, checklistItem, send) =>
  send(UpdateChecklistItem(ReviewChecklistItem.updateTitle(title, checklistItem), itemIndex))

let updateChecklistResultTitle = (
  itemIndex,
  resultIndex,
  title,
  reviewChecklistItem,
  resultItem,
  send,
) => {
  ReviewChecklistItem.results(reviewChecklistItem)
  ->ReviewChecklistResult.updateTitle(title, resultItem, resultIndex)
  ->ReviewChecklistItem.updateChecklist(reviewChecklistItem)
  ->(newReviewChecklistItem => UpdateChecklistItem(newReviewChecklistItem, itemIndex))
  ->send
}

let updateChecklistResultFeedback = (
  itemIndex,
  resultIndex,
  feedback,
  reviewChecklistItem,
  send,
) => {
  ReviewChecklistItem.results(reviewChecklistItem)
  ->ReviewChecklistResult.updateFeedback(feedback, resultIndex)
  ->ReviewChecklistItem.updateChecklist(reviewChecklistItem)
  ->(newReviewChecklistItem => UpdateChecklistItem(newReviewChecklistItem, itemIndex))
  ->send
}

let addEmptyResultItem = (send, reviewChecklistItem, itemIndex) =>
  ReviewChecklistItem.appendEmptyChecklistItem(reviewChecklistItem)
  ->(newReviewChecklistItem => UpdateChecklistItem(newReviewChecklistItem, itemIndex))
  ->send

let removeChecklistResult = (itemIndex, resultIndex, reviewChecklistItem, send) =>
  ReviewChecklistItem.deleteResultItem(resultIndex, reviewChecklistItem)
  ->(newReviewChecklistItem => UpdateChecklistItem(newReviewChecklistItem, itemIndex))
  ->send

let initialStateForReviewChecklist = reviewChecklist =>
  ArrayUtils.isEmpty(reviewChecklist) ? ReviewChecklistItem.emptyTemplate() : reviewChecklist

let invalidTitle = title => title->Js.String2.trim == ""

let invalidChecklist = reviewChecklist =>
  reviewChecklist
  ->Js.Array2.map(reviewChecklistItem =>
    invalidTitle(ReviewChecklistItem.title(reviewChecklistItem)) ||
    ReviewChecklistItem.results(reviewChecklistItem)
    ->Js.Array2.filter(resultItem => invalidTitle(ReviewChecklistResult.title(resultItem)))
    ->ArrayUtils.isNotEmpty
  )
  ->Js.Array2.filter(valid => valid)
  ->ArrayUtils.isNotEmpty

let reducer = (state, action) =>
  switch action {
  | SwapUpReviewChecklistItem(itemIndex) => {
      ...state,
      reviewChecklist: ArrayUtils.swapUp(itemIndex, state.reviewChecklist),
    }
  | SwapDownReviewChecklistItem(itemIndex) => {
      ...state,
      reviewChecklist: ArrayUtils.swapDown(itemIndex, state.reviewChecklist),
    }
  | UpdateChecklistItem(checklistItem, itemIndex) => {
      ...state,
      reviewChecklist: ReviewChecklistItem.replace(checklistItem, itemIndex, state.reviewChecklist),
    }
  | AddEmptyChecklistItem => {
      ...state,
      reviewChecklist: Js.Array2.concat(state.reviewChecklist, ReviewChecklistItem.empty()),
    }
  | RemoveChecklistItem(itemIndex) => {
      ...state,
      reviewChecklist: state.reviewChecklist->Js.Array2.filteri((_el, i) => i != itemIndex),
    }
  | UpdateSaving => {...state, saving: !state.saving}
  }

let controlIcon = (~icon, ~title, ~hidden=false, handler) =>
  ReactUtils.nullIf(
    <button
      ariaLabel=title
      title
      disabled={hidden}
      className="px-2 py-1 rounded text-sm bg-gray-100 text-gray-500 hover:bg-gray-300 hover:text-gray-900 overflow-hidden focus:outline-none focus:bg-gray-300 focus:text-gray-900"
      onClick={handler}>
      <i className={"fas fa-fw " ++ icon} />
    </button>,
    hidden,
  )

@react.component
let make = (~reviewChecklist, ~updateReviewChecklistCB, ~closeEditModeCB, ~targetId) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      reviewChecklist: initialStateForReviewChecklist(reviewChecklist),
      saving: false,
    },
  )

  <div>
    <div className="flex items-center px-4 md:px-6 py-3 bg-white border-b sticky top-0 z-50 h-16">
      <div className="flex flex-1 items-center justify-between">
        <h5 className="font-medium flex items-center tracking-wide">
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
        <div>
          {state.reviewChecklist
          ->Js.Array2.mapi((reviewChecklistItem, itemIndex) =>
            <Spread
              props={"data-checklist-item": string_of_int(itemIndex)}
              key={string_of_int(itemIndex)}>
              <div className="flex items-start gap-1">
                <div
                  className="p-3 md:p-5 mb-5 flex flex-col flex-1 bg-gray-100 rounded-lg"
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
                            send,
                          )}
                      />
                      <School__InputGroupError
                        message={t("checklist_title.error_message")}
                        active={invalidTitle(ReviewChecklistItem.title(reviewChecklistItem))}
                      />
                    </div>
                  </div>
                  <div>
                    {ReviewChecklistItem.results(reviewChecklistItem)
                    ->Js.Array2.mapi((resultItem, resultIndex) => {
                      let feedback = Belt.Option.getWithDefault(
                        ReviewChecklistResult.feedback(resultItem),
                        "",
                      )
                      <Spread
                        props={"data-result-item": string_of_int(resultIndex)}
                        key={string_of_int(itemIndex) ++ string_of_int(resultIndex)}>
                        <div className="ps-2 md:ps-4 mt-2">
                          <div className="flex">
                            <label
                              title={t("disabled")}
                              className="shrink-0 rounded border border-gray-300 bg-gray-50 w-4 h-4 me-2 mt-3 cursor-not-allowed"
                            />
                            <div className="w-full bg-gray-50 relative">
                              <div
                                className="flex justify-between gap-2 bg-white border border-gray-300 border-b-transparent rounded-t focus-within:outline-none focus-within:bg-white focus-within:border-primary-300">
                                <input
                                  className="checklist-editor__checklist-result-item-title border-none h-10 pe-0  focus:outline-none"
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
                                      send,
                                    )}
                                />
                                <div
                                  className="flex h-10 me-1 space-x-1 items-center justify-center">
                                  {controlIcon(
                                    ~icon="fa-arrow-up",
                                    ~title={t("checklist_item_title.move_up_button_title")},
                                    ~hidden={resultIndex <= 0},
                                    {
                                      _ =>
                                        send(
                                          UpdateChecklistItem(
                                            ReviewChecklistItem.moveResultItemUp(
                                              resultIndex,
                                              reviewChecklistItem,
                                            ),
                                            itemIndex,
                                          ),
                                        )
                                    },
                                  )}
                                  {controlIcon(
                                    ~icon="fa-arrow-down",
                                    ~title={t("checklist_item_title.move_down_button_title")},
                                    ~hidden={
                                      resultIndex ==
                                        Js.Array.length(
                                          ReviewChecklistItem.results(reviewChecklistItem),
                                        ) - 1
                                    },
                                    {
                                      _ =>
                                        send(
                                          UpdateChecklistItem(
                                            ReviewChecklistItem.moveResultItemDown(
                                              resultIndex,
                                              reviewChecklistItem,
                                            ),
                                            itemIndex,
                                          ),
                                        )
                                    },
                                  )}
                                  {controlIcon(
                                    ~icon="fa-trash-alt",
                                    ~title={t("checklist_item_title.remove_button_title")},
                                    {
                                      _ =>
                                        removeChecklistResult(
                                          itemIndex,
                                          resultIndex,
                                          reviewChecklistItem,
                                          send,
                                        )
                                    },
                                  )}
                                </div>
                              </div>
                              <textarea
                                rows=2
                                cols=33
                                className="appearance-none border border-gray-300 bg-transparent rounded-b text-sm align-top py-2 px-4 leading-relaxed w-full focus:outline-none focus:bg-white focus:border-primary-300"
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
                                    send,
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
                      onClick={_ => addEmptyResultItem(send, reviewChecklistItem, itemIndex)}
                      className="checklist-editor__add-result-btn ms-2 md:ms-4 mt-3 flex items-center focus:outline-none">
                      <span
                        title={t("add_result")}
                        className="checklist-editor__add-result-btn-check shrink-0 rounded border border-gray-300 bg-gray-50 w-4 h-4 me-2"
                      />
                      <span
                        className="checklist-editor__add-result-btn-text flex items-center text-sm font-semibold bg-gray-50 px-3 py-1 rounded border border-dashed border-gray-600">
                        <i className="fas fa-plus text-xs me-2" /> {t("add_result")->str}
                      </span>
                    </button>
                  </div>
                </div>
                <div
                  className="border border-gray-300 bg-white divide-y divide-gray-300 rounded flex flex-col text-xs sticky top-0 overflow-hidden">
                  {controlIcon(
                    ~icon="fa-arrow-up",
                    ~title={t("checklist_title.move_up_button_title")},
                    ~hidden={itemIndex <= 0},
                    {
                      _ => send(SwapUpReviewChecklistItem(itemIndex))
                    },
                  )}
                  {controlIcon(
                    ~icon="fa-arrow-down",
                    ~title={t("checklist_title.move_down_button_title")},
                    ~hidden={itemIndex == Js.Array.length(state.reviewChecklist) - 1},
                    {
                      _ => send(SwapDownReviewChecklistItem(itemIndex))
                    },
                  )}
                  {controlIcon(
                    ~icon="fa-trash-alt",
                    ~title={t("checklist_title.remove_button_title")},
                    {_ => send(RemoveChecklistItem(itemIndex))},
                  )}
                </div>
              </div>
            </Spread>
          )
          ->React.array}
          <div>
            <button
              ariaLabel={t("add_checklist_item")}
              className="flex items-center text-sm font-semibold bg-white rounded-md border border-dashed border-gray-600 w-full hover:text-primary-500 hover:bg-white hover:border-primary-500 hover:shadow-md focus:outline-none focus:text-primary-500 focus:bg-white focus:border-primary-500 focus:shadow-md"
              onClick={_ => send(AddEmptyChecklistItem)}>
              <span className="bg-gray-100 py-2 w-10 text-center">
                <i className="fas fa-plus text-sm" />
              </span>
              <span className="px-3 py-2"> {t("add_checklist_item")->str} </span>
            </button>
          </div>
        </div>
      </div>
      <div className="flex bg-gray-50 border-t flex-row-reverse sticky bottom-0 px-4 py-2 md:py-4">
        <button
          disabled={state.saving || invalidChecklist(state.reviewChecklist)}
          onClick={_ =>
            updateReviewChecklist(targetId, state.reviewChecklist, send, updateReviewChecklistCB)}
          className="btn btn-success">
          {t("save_checklist")->str}
        </button>
        <button className="btn btn-subtle me-4" onClick={_ => closeEditModeCB()}>
          {t("cancel")->str}
        </button>
      </div>
    </DisablingCover>
  </div>
}
