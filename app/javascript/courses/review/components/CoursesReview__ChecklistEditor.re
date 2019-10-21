[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

open CoursesReview__Types;

type state = {
  reviewChecklist: array(ReviewChecklistItem.t),
  saving: bool,
};

// let updateChecklistItemTitle = (itemIndex, title, checklist) => checklist |> Array.l(title))
// let updateChecklistResultTitle = (itemIndex, resultIndex, title, checklist)
// let updateChecklistResultFeedback = (itemIndex, resultIndex, feedback, checklist)

let str = React.string;

let updateChecklist = (checklistItem, index, setState) => {
  setState(state =>
    {
      ...state,
      reviewChecklist:
        state.reviewChecklist
        |> ReviewChecklistItem.replace(checklistItem, index),
    }
  );
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
         |> ReviewChecklistItem.checklist
         |> ReviewChecklistResult.updateTitle(title, resultItem, resultIndex),
       );
  updateChecklistItem(newReviewChecklistItem, itemIndex, setState);
};

[@react.component]
let make = (~reviewChecklist, ~updateReviewChecklistCB, ~closeEditModeCB) => {
  let (state, setState) =
    React.useState(() => {reviewChecklist, saving: false});
  <div>
    {state.reviewChecklist
     |> Array.mapi((itemIndex, reviewChecklistItem) =>
          <div className="mt-2" key={itemIndex |> string_of_int}>
            <div className="mt-5">
              <input
                className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
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
                message="Title should greate than 2 charcahters"
                active={reviewChecklistItem |> ReviewChecklistItem.title == ""}
              />
            </div>
            <div>
              {reviewChecklistItem
               |> ReviewChecklistItem.checklist
               |> Array.mapi((resultIndex, resultItem) => {
                    let feedback =
                      switch (resultItem |> ReviewChecklistResult.feedback) {
                      | Some(f) => f
                      | None => ""
                      };
                    <div
                      className="px-2 mt-2"
                      key={
                        (itemIndex |> string_of_int)
                        ++ (resultIndex |> string_of_int)
                      }>
                      <div className="flex">
                        // <Checkbox id="" label="" onChange=checkboxOnChange />

                          <div
                            className="w-full bg-white border border-gray-400 rounded">
                            <div className="">
                              <input
                                className="appearance-none py-1 px-4 mt-2 leading-tight w-full focus:outline-none focus:bg-white focus:border-gray-500"
                                id="checklist_title"
                                type_="text"
                                placeholder="Add title for checklist item"
                                value={
                                  resultItem |> ReviewChecklistResult.title
                                }
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
                                message="Title should greate than 2 charcahters"
                                active={
                                  resultItem
                                  |> ReviewChecklistResult.title == ""
                                }
                              />
                            </div>
                            <textarea
                              className="appearance-none border-t border-gray-400 py-1 px-4 leading-tight w-full bg-gray-200  focus:outline-none focus:bg-white focus:border-gray-500"
                              id="checklist_description"
                              type_="text"
                              placeholder="Add description for checklist item"
                              value=feedback
                              onChange={event =>
                                updateChecklist(
                                  reviewChecklistItem
                                  |> ReviewChecklistItem.updateChecklist(
                                       reviewChecklistItem
                                       |> ReviewChecklistItem.checklist
                                       |> ReviewChecklistResult.updateFeedback(
                                            ReactEvent.Form.target(event)##value,
                                            resultItem,
                                            resultIndex,
                                          ),
                                     ),
                                  itemIndex,
                                  setState,
                                )
                              }
                            />
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
                      updateChecklist(
                        reviewChecklistItem
                        |> ReviewChecklistItem.appendEmptyChecklistItem,
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
        onClick={_ =>
          setState(state =>
            {
              ...state,
              reviewChecklist:
                ReviewChecklistItem.empty()
                |> Array.append(state.reviewChecklist),
            }
          )
        }>
        {"Add Checklist Item" |> str}
      </button>
    </div>
    <div className="py-2 mt-4 flex">
      <button
        onClick={_ => updateReviewChecklistCB(state.reviewChecklist)}
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
