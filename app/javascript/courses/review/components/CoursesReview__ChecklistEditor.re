[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__ChecklistEditor.css")|}];

open CoursesReview__Types;

type state = {
  reviewChecklist: array(ReviewChecklistItem.t),
  saving: bool,
};

let str = React.string;

module UpdateReviewChecklistMutation = [%graphql
  {|
    mutation($targetId: ID!, $reviewChecklist: JSON!) {
      updateReviewChecklist(targetId: $targetId, reviewChecklist: $reviewChecklist){
        success
      }
    }
  |}
];

let updateReviewChecklist =
    (targetId, reviewChecklist, setState, updateReviewChecklistCB) => {
  setState(state => {...state, saving: true});

  UpdateReviewChecklistMutation.make(
    ~targetId,
    ~reviewChecklist=
      CoursesReview__ReviewChecklistItem.encode(reviewChecklist),
    (),
  )
  |> GraphqlQuery.sendQuery(AuthenticityToken.fromHead())
  |> Js.Promise.then_(response => {
       response##updateReviewChecklist##success
         ? {
           updateReviewChecklistCB(reviewChecklist);
           setState(state => {...state, saving: false});
         }
         : setState(state => {...state, saving: false});
       Js.Promise.resolve();
     })
  |> ignore;
};

let updateChecklistItem = (checklistItem, itemIndex, setState) => {
  setState(state =>
    {
      ...state,
      reviewChecklist:
        state.reviewChecklist
        |> ReviewChecklistItem.replace(checklistItem, itemIndex),
    }
  );
};

let updateChecklistItemTitle = (itemIndex, title, checklistItem, setState) => {
  updateChecklistItem(
    ReviewChecklistItem.updateTitle(title, checklistItem),
    itemIndex,
    setState,
  );
};

let updateChecklistResultTitle =
    (itemIndex, resultIndex, title, reviewChecklistItem, resultItem, setState) => {
  let newReviewChecklistItem =
    reviewChecklistItem
    |> ReviewChecklistItem.updateChecklist(
         reviewChecklistItem
         |> ReviewChecklistItem.result
         |> ReviewChecklistResult.updateTitle(title, resultItem, resultIndex),
       );
  updateChecklistItem(newReviewChecklistItem, itemIndex, setState);
};

let updateChecklistResultFeedback =
    (
      itemIndex,
      resultIndex,
      feedback,
      reviewChecklistItem,
      resultItem,
      setState,
    ) => {
  let newReviewChecklistItem =
    reviewChecklistItem
    |> ReviewChecklistItem.updateChecklist(
         reviewChecklistItem
         |> ReviewChecklistItem.result
         |> ReviewChecklistResult.updateFeedback(
              feedback,
              resultItem,
              resultIndex,
            ),
       );
  updateChecklistItem(newReviewChecklistItem, itemIndex, setState);
};

let addEmptyResultItem = (reviewChecklistItem, itemIndex, setState) => {
  updateChecklistItem(
    reviewChecklistItem |> ReviewChecklistItem.appendEmptyChecklistItem,
    itemIndex,
    setState,
  );
};

let addEmptyChecklistItem = setState => {
  setState(state =>
    {
      ...state,
      reviewChecklist:
        ReviewChecklistItem.empty() |> Array.append(state.reviewChecklist),
    }
  );
};

let removeChecklistResult =
    (itemIndex, resultIndex, reviewChecklistItem, setState) => {
  updateChecklistItem(
    reviewChecklistItem |> ReviewChecklistItem.deleteResultItem(resultIndex),
    itemIndex,
    setState,
  );
};

let removeChecklistItem = (itemIndex, setState) => {
  setState(state =>
    {
      ...state,
      reviewChecklist:
        state.reviewChecklist |> Js.Array.filteri((_el, i) => i != itemIndex),
    }
  );
};

let initialStateForReviewChecklist = reviewChecklist => {
  reviewChecklist |> ArrayUtils.isEmpty
    ? ReviewChecklistItem.emptyTemplate() : reviewChecklist;
};

[@react.component]
let make =
    (~reviewChecklist, ~updateReviewChecklistCB, ~closeEditModeCB, ~targetId) => {
  let (state, setState) =
    React.useState(() =>
      {
        reviewChecklist: reviewChecklist |> initialStateForReviewChecklist,
        saving: false,
      }
    );
  <div>
    {state.reviewChecklist
     |> Array.mapi((itemIndex, reviewChecklistItem) =>
          <div className="mt-2" key={itemIndex |> string_of_int}>
            <div className="flex items-center">
              <div className="w-full">
                <input
                  className="checklist-editor__checklist-item-title focus:outline-none focus:bg-white focus:border-primary-300"
                  id="checklist_title"
                  type_="text"
                  placeholder="Add title for checklist item"
                  value={reviewChecklistItem |> ReviewChecklistItem.title}
                  onChange={event =>
                    updateChecklistItemTitle(
                      itemIndex,
                      ReactEvent.Form.target(event)##value,
                      reviewChecklistItem,
                      setState,
                    )
                  }
                />
                <School__InputGroupError
                  message="Title should be greater than 2 characters"
                  active={
                    reviewChecklistItem |> ReviewChecklistItem.title == ""
                  }
                />
              </div>
              <div
                className="btn btn-primary m-2"
                onClick={_ => removeChecklistItem(itemIndex, setState)}>
                {"delete" |> str}
              </div>
            </div>
            <div>
              {reviewChecklistItem
               |> ReviewChecklistItem.result
               |> Array.mapi((resultIndex, resultItem) => {
                    let feedback =
                      switch (resultItem |> ReviewChecklistResult.feedback) {
                      | Some(f) => f
                      | None => ""
                      };
                    <div
                      className="px-2 md:px-4 mt-2"
                      key={
                        (itemIndex |> string_of_int)
                        ++ (resultIndex |> string_of_int)
                      }>
                      <div className="flex">
                        <label
                          title="Disabled"
                          className="flex-shrink-0 rounded border border-gray-400 bg-gray-100 w-4 h-4 mr-2 mt-3 cursor-not-allowed"
                        />
                        <div className="w-full bg-gray-100">
                          <div>
                            <input
                              className="checklist-editor__checklist-result-item-title focus:outline-none focus:bg-white focus:border-primary-300"
                              id={
                                "result_"
                                ++ (resultIndex |> string_of_int)
                                ++ "_title"
                              }
                              type_="text"
                              placeholder="Add title for checklist item"
                              value={resultItem |> ReviewChecklistResult.title}
                              onChange={event =>
                                updateChecklistResultTitle(
                                  itemIndex,
                                  resultIndex,
                                  ReactEvent.Form.target(event)##value,
                                  reviewChecklistItem,
                                  resultItem,
                                  setState,
                                )
                              }
                            />
                            <School__InputGroupError
                              message="Title should be greater than 2 characters"
                              active={
                                resultItem |> ReviewChecklistResult.title == ""
                              }
                            />
                          </div>
                          <textarea
                            className="appearance-none border border-gray-400 bg-transparent rounded-b text-sm py-2 px-4 leading-tight w-full focus:outline-none focus:bg-white focus:border-primary-300"
                            id={
                              "result_"
                              ++ (resultIndex |> string_of_int)
                              ++ "_feedback"
                            }
                            type_="text"
                            placeholder="Add feedback"
                            value=feedback
                            onChange={event =>
                              updateChecklistResultFeedback(
                                itemIndex,
                                resultIndex,
                                ReactEvent.Form.target(event)##value,
                                reviewChecklistItem,
                                resultItem,
                                setState,
                              )
                            }
                          />
                        </div>
                        <div
                          className="btn btn-primary m-2"
                          onClick={_ =>
                            removeChecklistResult(
                              itemIndex,
                              resultIndex,
                              reviewChecklistItem,
                              setState,
                            )
                          }>
                          {"delete" |> str}
                        </div>
                      </div>
                    </div>;
                  })
               |> React.array}
              <div className="py-1 mt-2 flex px-2">
                // <Checkbox id="" label="" onChange=checkboxOnChange />

                  <button
                    className="bg-gray-400 px-2 py-1 btn"
                    onClick={_ =>
                      addEmptyResultItem(
                        reviewChecklistItem,
                        itemIndex,
                        setState,
                      )
                    }>
                    {"Add feedback template" |> str}
                  </button>
                </div>
            </div>
          </div>
        )
     |> React.array}
    <div className="py-2 mt-2">
      <button
        className="bg-gray-400 px-2 py-1 btn w-full"
        onClick={_ => addEmptyChecklistItem(setState)}>
        {"Add Checklist Item" |> str}
      </button>
    </div>
    <div className="py-2 mt-4 flex">
      <button
        onClick={_ =>
          updateReviewChecklist(
            targetId,
            state.reviewChecklist,
            setState,
            updateReviewChecklistCB,
          )
        }
        className="btn btn-primary">
        {"Save Checklist" |> str}
      </button>
      <button
        className="btn btn-primary-ghost ml-2"
        onClick={_ => closeEditModeCB()}>
        {"Close" |> str}
      </button>
    </div>
  </div>;
};
