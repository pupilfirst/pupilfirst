[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

open CoursesReview__Types;

type selectionItem = {
  itemIndex: int,
  resultIndex: int,
};

type selection = list(selectionItem);

let str = React.string;

let selectChecklist = (itemIndex, resultIndex, setSelecton) => {
  setSelecton(selection =>
    selection |> List.append([{itemIndex, resultIndex}])
  );
};

let unSelectChecklist = (itemIndex, resultIndex, setSelecton) => {
  setSelecton(selection =>
    selection
    |> List.filter(item =>
         !(item.itemIndex == itemIndex && item.resultIndex == resultIndex)
       )
  );
};

let checkboxOnChange = (itemIndex, resultIndex, setSelecton, event) => {
  ReactEvent.Form.target(event)##checked
    ? selectChecklist(itemIndex, resultIndex, setSelecton)
    : unSelectChecklist(itemIndex, resultIndex, setSelecton);
};

let generateFeedback =
    (reviewChecklist, selection, feedback, updateFeedbackCB) => {
  let newFeedback =
    feedback
    ++ "\n\n"
    ++ (
      reviewChecklist
      |> Array.mapi((i, reviewChecklistItem) => {
           let resultIndexList =
             selection
             |> List.filter(selectionItem => selectionItem.itemIndex == i)
             |> List.map(item => item.resultIndex);

           reviewChecklistItem
           |> ReviewChecklistItem.result
           |> Array.mapi((index, resultItem) =>
                resultIndexList |> List.mem(index)
                  ? switch (resultItem |> ReviewChecklistResult.feedback) {
                    | Some(feedback) => [feedback]
                    | None => []
                    }
                  : []
              )
           |> Array.to_list
           |> List.flatten;
         })
      |> Array.to_list
      |> List.flatten
      |> Array.of_list
      |> Js.Array.joinWith("\n\n")
    );
  updateFeedbackCB(newFeedback);
};

[@react.component]
let make = (~reviewChecklist, ~feedback, ~updateFeedbackCB, ~showEditorCB) => {
  let (selection, setSelecton) = React.useState(() => []);

  <div className="relative bg-gray-100 rounded-sm p-2 md:p-4">
    <div
      className="relative w-full md:absolute md:w-auto right-0 top-0 mt-2 mr-2 md:mt-4 md:mr-4">
      <button
        className="btn btn-small btn-primary-ghost w-full md:w-auto"
        onClick={_ => showEditorCB()}>
        {"Edit Checklist" |> str}
      </button>
    </div>
    {reviewChecklist
     |> Array.mapi((i, reviewChecklistItem) =>
          <div className="" key={i |> string_of_int}>
            <h4
              className="text-base font-semibold mt-4 md:mt-0 w-full md:w-4/5">
              {reviewChecklistItem |> ReviewChecklistItem.title |> str}
            </h4>
            <div>
              {reviewChecklistItem
               |> ReviewChecklistItem.result
               |> Array.mapi((index, checklistItem) =>
                    <div
                      className="px-2 md:px-4 mt-2"
                      key={(i |> string_of_int) ++ (index |> string_of_int)}>
                      <Checkbox
                        id={
                          "review_checkbox"
                          ++ (i |> string_of_int)
                          ++ (index |> string_of_int)
                        }
                        label={checklistItem |> ReviewChecklistResult.title}
                        onChange={checkboxOnChange(i, index, setSelecton)}
                      />
                      <div className="pl-7 pb-2">
                        <CoursesReview__ChecklistShowFeedback
                          feedback={
                            checklistItem |> ReviewChecklistResult.feedback
                          }
                        />
                      </div>
                    </div>
                  )
               |> React.array}
            </div>
          </div>
        )
     |> React.array}
    <div className="text-center max-w-xs mx-auto mt-6">
      <button
        className="btn btn-primary btn-large w-full "
        disabled={selection |> ListUtils.isEmpty}
        onClick={_ =>
          generateFeedback(
            reviewChecklist,
            selection,
            feedback,
            updateFeedbackCB,
          )
        }>
        {"Generate Feedback" |> str}
      </button>
    </div>
  </div>;
};
