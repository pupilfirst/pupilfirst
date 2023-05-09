open CoursesReview__Types

type selectionItem = {
  itemIndex: int,
  resultIndex: int,
}

let str = React.string

let t = I18n.t(~scope="components.CoursesReview__ChecklistShow")

let selectChecklist = (itemIndex, resultIndex, setSelecton) =>
  setSelecton(selection =>
    Js.Array2.concat(selection, [{itemIndex: itemIndex, resultIndex: resultIndex}])
  )

let updateEmptyChecklistResult = (
  itemIndex,
  resultIndex,
  feedback,
  reviewChecklistItem,
  setChecklist,
) => {
  ReviewChecklistItem.results(reviewChecklistItem)
  ->ReviewChecklistResult.updateAdditionalFeedback(feedback, resultIndex)
  ->ReviewChecklistItem.updateChecklist(reviewChecklistItem)
  ->ReviewChecklistItem.replace(itemIndex)
  ->setChecklist
}

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
  let newFeedback =
    feedback ++
    ((String.trim(feedback) == "" ? "" : "\n\n") ++
    checklist
    ->Js.Array2.mapi((reviewChecklistItem, i) => {
      let resultIndexList =
        selection
        ->Js.Array2.filter(selectionItem => selectionItem.itemIndex == i)
        ->Js.Array2.map(item => item.resultIndex)

      ReviewChecklistItem.results(reviewChecklistItem)
      ->Js.Array2.mapi((resultItem, index) =>
        resultIndexList->Js.Array2.some(i => i == index)
          ? switch ReviewChecklistResult.feedback(resultItem) {
            | Some(feedback) => [feedback]
            | None => []
            }
          : []
      )
      ->ArrayUtils.flattenV2
    })
    ->ArrayUtils.flattenV2
    ->Js.Array2.joinWith("\n\n"))
  setSelecton(_ => [])
  updateFeedbackCB(newFeedback)
}

let checklistItemCheckedClasses = (itemIndex, selection) =>
  "absolute w-1 inset-0 rounded-e-md " ++ (
    Js.Array.filter(s => s.itemIndex == itemIndex, selection)->ArrayUtils.isNotEmpty
      ? "bg-green-400"
      : "bg-gray-500"
  )

let feedbackGeneratable = (submissionDetails, overlaySubmission) => {
  SubmissionDetails.reviewer(submissionDetails)->Belt.Option.isSome ||
    OverlaySubmission.evaluatedAt(overlaySubmission)->Belt.Option.isSome
}

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
  setChecklist,
) => {
  ReviewChecklistItem.results(reviewChecklistItem)
  ->ReviewChecklistResult.updateFeedback(feedback, resultIndex)
  ->ReviewChecklistItem.updateChecklist(reviewChecklistItem)
  ->ReviewChecklistItem.replace(itemIndex)
  ->setChecklist
}

let generateFeedbackButton = (checklist, selection, feedback, setSelecton, updateFeedbackCB) => {
  <button
    className="btn btn-primary w-full md:w-auto"
    disabled={selection->ArrayUtils.isEmpty}
    onClick={_ => generateFeedback(checklist, selection, feedback, setSelecton, updateFeedbackCB)}>
    {t("generate_feedback_button")->str}
  </button>
}

@react.component
let make = (
  ~reviewChecklist,
  ~feedback,
  ~updateFeedbackCB,
  ~showEditorCB,
  ~cancelCB,
  ~overlaySubmission,
  ~submissionDetails,
) => {
  let (checklist, setChecklist) = React.useState(() => reviewChecklist)
  let (selection, setSelecton) = React.useState(() => [])
  let (id, _setId) = React.useState(() => DateTime.randomId() ++ "-review-checkbox-")

  let hasFeedbackTemplate = Js.Array.map(item => {
    Js.Array.map(result => {
      switch ReviewChecklistResult.feedback(result) {
      | Some(_) => true
      | None => false
      }
    }, ReviewChecklistItem.results(item))
  }, reviewChecklist)

  <div>
    <div className="flex items-center px-4 md:px-6 py-3 bg-white border-b sticky top-0 z-50 h-16">
      <div className="flex flex-1 items-center justify-between">
        <button
          className="btn btn-subtle focus:ring-2 focus:ring-offset-2 focus:ring-focusColor-500 transition"
          onClick=cancelCB>
          <FaIcon classes="fas fa-arrow-left text-gray-500" />
          <p className="ps-2 "> {str(t("back_to_review"))} </p>
        </button>
      </div>
    </div>
    <div className="p-4 md:px-6 pb-0">
      <div className="flex items-end justify-between">
        <h5 className="font-semibold flex items-center tracking-wide text-sm">
          {t("review_checklist")->str}
        </h5>
        <button className="btn btn-small btn-default" onClick={_ => showEditorCB()}>
          <i className="far fa-edit" />
          <div className="ms-2"> {t("edit_checklist_button")->str} </div>
        </button>
      </div>
      <div className="border bg-white rounded-lg py-2 md:py-4 mt-2 space-y-4">
        {Js.Array.mapi(
          (reviewChecklistItem, itemIndex) =>
            <Spread
              props={"data-checklist-item": string_of_int(itemIndex)}
              key={string_of_int(itemIndex)}>
              <div>
                <h4 className="relative text-sm font-semibold mt-2 md:mt-0 px-6 w-full md:w-4/5">
                  <div className={checklistItemCheckedClasses(itemIndex, selection)} />
                  {ReviewChecklistItem.title(reviewChecklistItem)->str}
                </h4>
                <div className="space-y-3 pt-3">
                  {Js.Array.mapi((reviewChecklistResult, resultIndex) =>
                    <Spread
                      props={"data-result-item": string_of_int(resultIndex)}
                      key={string_of_int(itemIndex) ++ string_of_int(resultIndex)}>
                      {switch Belt.Option.isSome(
                        ReviewChecklistResult.feedback(reviewChecklistResult),
                      ) &&
                      hasFeedbackTemplate[itemIndex][resultIndex] == true {
                      | true =>
                        <div className="px-6">
                          <Checkbox
                            id={id ++ (itemIndex->string_of_int ++ resultIndex->string_of_int)}
                            label={str(reviewChecklistResult->ReviewChecklistResult.title)}
                            onChange={checkboxOnChange(itemIndex, resultIndex, setSelecton)}
                            checked={checklistItemChecked(itemIndex, resultIndex, selection)}
                            disabled={!feedbackGeneratable(submissionDetails, overlaySubmission)}
                          />
                          {
                            let isSelected =
                              Js.Array.find(
                                s => s.itemIndex == itemIndex && s.resultIndex == resultIndex,
                                selection,
                              )->Belt.Option.isSome
                            ReactUtils.nullUnless(
                              <div
                                id={"result_item_" ++ (resultIndex->string_of_int ++ "_feedback")}
                                className="ps-7 pt-2">
                                <textarea
                                  rows=4
                                  cols=33
                                  className="appearance-none border border-gray-300 bg-white rounded-b text-sm align-top py-2 px-4 leading-relaxed w-full focus:outline-none focus:bg-white focus:border-primary-300"
                                  id={"result_" ++ (resultIndex->string_of_int ++ "_feedback")}
                                  type_="text"
                                  placeholder={t("feedback_placeholder")}
                                  disabled={!feedbackGeneratable(
                                    submissionDetails,
                                    overlaySubmission,
                                  )}
                                  value={Belt.Option.getWithDefault(
                                    ReviewChecklistResult.feedback(reviewChecklistResult),
                                    "",
                                  )}
                                  onChange={event =>
                                    updateChecklistResultFeedback(
                                      itemIndex,
                                      resultIndex,
                                      ReactEvent.Form.target(event)["value"],
                                      reviewChecklistItem,
                                      setChecklist,
                                    )}
                                />
                              </div>,
                              (isSelected ||
                              !feedbackGeneratable(submissionDetails, overlaySubmission)) &&
                                Belt.Option.isSome(
                                  ReviewChecklistResult.feedback(reviewChecklistResult),
                                ),
                            )
                          }
                        </div>
                      | false =>
                        <div className="px-6">
                          <div className="flex flex-wrap">
                            <Checkbox
                              id={id ++ (itemIndex->string_of_int ++ resultIndex->string_of_int)}
                              label={str(reviewChecklistResult->ReviewChecklistResult.title)}
                              onChange={checkboxOnChange(itemIndex, resultIndex, setSelecton)}
                              checked={checklistItemChecked(itemIndex, resultIndex, selection)}
                              disabled={!feedbackGeneratable(submissionDetails, overlaySubmission)}
                            />
                            {
                              let isSelected =
                                Js.Array.find(
                                  s => s.itemIndex == itemIndex && s.resultIndex == resultIndex,
                                  selection,
                                )->Belt.Option.isSome

                              let hasFeedback = Belt.Option.isSome(
                                ReviewChecklistResult.feedback(reviewChecklistResult),
                              )
                              switch (isSelected, hasFeedback) {
                              | (true, true) =>
                                <div
                                  id={"result_item_" ++ (resultIndex->string_of_int ++ "_feedback")}
                                  className="pl-7 pt-2 w-full">
                                  <textarea
                                    rows=4
                                    cols=33
                                    className="appearance-none border border-gray-300 bg-white rounded-b text-sm align-top py-2 px-4 leading-relaxed w-full focus:outline-none focus:bg-white focus:border-primary-300"
                                    id={"checklist_" ++
                                    itemIndex->string_of_int ++
                                    "_result_" ++
                                    (resultIndex->string_of_int ++
                                    "_text_area")}
                                    type_="text"
                                    placeholder={t("feedback_placeholder")}
                                    disabled={!feedbackGeneratable(
                                      submissionDetails,
                                      overlaySubmission,
                                    )}
                                    value={Belt.Option.getWithDefault(
                                      ReviewChecklistResult.feedback(reviewChecklistResult),
                                      "",
                                    )}
                                    onChange={event =>
                                      updateChecklistResultFeedback(
                                        itemIndex,
                                        resultIndex,
                                        ReactEvent.Form.target(event)["value"],
                                        reviewChecklistItem,
                                        setChecklist,
                                      )}
                                  />
                                </div>
                              | (true, false) =>
                                <button
                                  id={"add-additional-feedback-" ++ string_of_int(itemIndex)}
                                  className="w-auto ps-4 text-sm text-primary-500 text-left rtl:text-right  hover:text-primary-600 transition"
                                  onClick={event =>
                                    updateEmptyChecklistResult(
                                      itemIndex,
                                      resultIndex,
                                      Some(""),
                                      reviewChecklistItem,
                                      setChecklist,
                                    )}>
                                  <i className="fas fa-plus" />
                                  <span className="ps-2 ">
                                    {str(t("add_additional_feedback"))}
                                  </span>
                                </button>
                              | (false, true) =>
                                updateEmptyChecklistResult(
                                  itemIndex,
                                  resultIndex,
                                  None,
                                  reviewChecklistItem,
                                  setChecklist,
                                )
                                React.null
                              | (false, false) => React.null
                              }
                            }
                          </div>
                        </div>
                      }}
                    </Spread>
                  , ReviewChecklistItem.results(reviewChecklistItem))->React.array}
                </div>
              </div>
            </Spread>,
          checklist,
        )->React.array}
      </div>
    </div>
    <div
      className="flex justify-end border-t bg-gray-50 opacity-90 sticky bottom-0 px-4 md:px-6 py-2 md:py-4 mt-4">
      {feedbackGeneratable(submissionDetails, overlaySubmission)
        ? generateFeedbackButton(checklist, selection, feedback, setSelecton, updateFeedbackCB)
        : React.null}
    </div>
  </div>
}
