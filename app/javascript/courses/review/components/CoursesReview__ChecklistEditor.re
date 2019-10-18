[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

open CoursesReview__Types;

type state = {
  reviewChecklist: array(ReviewChecklist.t),
  selectedChecklist: array(ReviewChecklist.t),
  saving: bool,
  editMode: bool,
};

let str = React.string;

let showCheckList = (checklist, setState) =>
  <div>
    <div className="flex justify-end px-4">
      <button
        className="btn btn-primary mt-2"
        onClick={_ => setState(state => {...state, editMode: true})}>
        {"Edit Checklist" |> str}
      </button>
    </div>
    {checklist
     |> Array.mapi((i, reviewChecklistItem) =>
          <div className="mt-2" key={i |> string_of_int}>
            <div className="text-lg font-semibold mt-2">
              {reviewChecklistItem |> ReviewChecklist.title |> str}
            </div>
            <div>
              {reviewChecklistItem
               |> ReviewChecklist.checklist
               |> Array.mapi((index, checklistItem) =>
                    <div
                      className="px-2 mt-2"
                      key={(i |> string_of_int) ++ (index |> string_of_int)}>
                      <Checkbox
                        id={
                          "review_checkbox"
                          ++ (i |> string_of_int)
                          ++ (index |> string_of_int)
                        }
                        label={checklistItem |> ReviewChecklistResult.title}
                      />
                      <div className="pl-7">
                        {switch (
                           checklistItem |> ReviewChecklistResult.feedback
                         ) {
                         | Some(feedback) =>
                           <div className="text-xs"> {feedback |> str} </div>
                         | None => React.null
                         }}
                      </div>
                    </div>
                  )
               |> React.array}
            </div>
          </div>
        )
     |> React.array}
  </div>;

let updateChecklist = (checklistItem, index, setState) => {
  setState(state =>
    {
      ...state,
      reviewChecklist:
        state.reviewChecklist |> ReviewChecklist.replace(checklistItem, index),
    }
  );
};

let showCheckListEdit = (checklist, setState, closeEditModeCB) => {
  <div>
    {checklist
     |> Array.mapi((i, reviewChecklistItem) =>
          <div className="mt-2" key={i |> string_of_int}>
            <div className="mt-5">
              <input
                className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                id="checklist_title"
                type_="text"
                placeholder="Add title for checklist item"
                value={reviewChecklistItem |> ReviewChecklist.title}
                onChange={event =>
                  updateChecklist(
                    reviewChecklistItem
                    |> ReviewChecklist.updateTitle(
                         ReactEvent.Form.target(event)##value,
                       ),
                    i,
                    setState,
                  )
                }
              />
              <School__InputGroupError
                message="Title should greate than 2 charcahters"
                active={reviewChecklistItem |> ReviewChecklist.title == ""}
              />
            </div>
            <div>
              {reviewChecklistItem
               |> ReviewChecklist.checklist
               |> Array.mapi((index, checklistItem) => {
                    let feedback =
                      switch (checklistItem |> ReviewChecklistResult.feedback) {
                      | Some(f) => f
                      | None => ""
                      };
                    <div
                      className="px-2 mt-2"
                      key={(i |> string_of_int) ++ (index |> string_of_int)}>
                      <div className="flex">
                        <Checkbox id="" label="" />
                        <div
                          className="w-full bg-white border border-gray-400 rounded">
                          <div className="">
                            <input
                              className="appearance-none py-1 px-4 mt-2 leading-tight w-full focus:outline-none focus:bg-white focus:border-gray-500"
                              id="checklist_title"
                              type_="text"
                              placeholder="Add title for checklist item"
                              value={
                                checklistItem |> ReviewChecklistResult.title
                              }
                              onChange={event =>
                                updateChecklist(
                                  reviewChecklistItem
                                  |> ReviewChecklist.updateChecklist(
                                       reviewChecklistItem
                                       |> ReviewChecklist.checklist
                                       |> ReviewChecklistResult.updateTitle(
                                            ReactEvent.Form.target(event)##value,
                                            checklistItem,
                                            index,
                                          ),
                                     ),
                                  i,
                                  setState,
                                )
                              }
                            />
                            <School__InputGroupError
                              message="Title should greate than 2 charcahters"
                              active={
                                checklistItem
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
                                |> ReviewChecklist.updateChecklist(
                                     reviewChecklistItem
                                     |> ReviewChecklist.checklist
                                     |> ReviewChecklistResult.updateFeedback(
                                          ReactEvent.Form.target(event)##value,
                                          checklistItem,
                                          index,
                                        ),
                                   ),
                                i,
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
                <Checkbox id="" label="" />
                <button
                  className="bg-gray-400 px-2 py-1 btn"
                  onClick={_ =>
                    updateChecklist(
                      reviewChecklistItem
                      |> ReviewChecklist.appendEmptyChecklistItem,
                      i,
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
                ReviewChecklist.empty() |> Array.append(state.reviewChecklist),
            }
          )
        }>
        {"Add Checklist Item" |> str}
      </button>
    </div>
    <div className="py-2 mt-4 flex">
      <button className="btn btn-primary"> {"Save Checklist" |> str} </button>
      <button
        className="btn btn-primary-ghost ml-2"
        onClick={_ => closeEditModeCB(setState)}>
        {"Close" |> str}
      </button>
    </div>
  </div>;
};

let handleEmptyReviewCheckList = reviewChecklist => {
  reviewChecklist |> ArrayUtils.isEmpty
    ? ReviewChecklist.empty() : reviewChecklist;
};

let closeEditMode = (reviewChecklist, setState) => {
  setState(state => {...state, editMode: false, reviewChecklist});
};

[@react.component]
let make = (~reviewChecklist) => {
  let (state, setState) =
    React.useState(() =>
      {
        reviewChecklist: handleEmptyReviewCheckList(reviewChecklist),
        selectedChecklist: [||],
        editMode: true,
        saving: false,
      }
    );
  <div className="">
    <div>
      <div className="text-xl"> {"Review Prep Checklist" |> str} </div>
      <div className="text-sm">
        {"Prepare for your review by creating a checklist" |> str}
      </div>
    </div>
    <div className="bg-gray-300 rounded-lg mt-2">
      <div className="px-4">
        {state.editMode
           ? showCheckListEdit(
               state.reviewChecklist,
               setState,
               closeEditMode(reviewChecklist),
             )
           : showCheckList(state.reviewChecklist, setState)}
      </div>
    </div>
    <button className="btn btn-primary mt-4 w-full" disabled={state.editMode}>
      {"Generate Feedback" |> str}
    </button>
  </div>;
};
