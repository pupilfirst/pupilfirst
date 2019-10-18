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
         item.itemIndex != itemIndex && item.resultIndex != resultIndex
       )
  );
};

let checkboxOnChange = (itemIndex, resultIndex, setSelecton, event) => {
  ReactEvent.Form.target(event)##checked
    ? selectChecklist(itemIndex, resultIndex, setSelecton)
    : unSelectChecklist(itemIndex, resultIndex, setSelecton);
};

let generateFeedback = (reviewChecklist, selection, updateFeedbackCB) => {
  ()//        // reviewChecklistItem
    //   reviewChecklist
    ; //        => selection |> List.mem(target |> Target.targetGroupId))
 //   |> Array.mapi((i, reviewChecklistItem)
    // ;
};

[@react.component]
let make = (~reviewChecklist, ~updateFeedbackCB, ~showEditorCB) => {
  let (selection, setSelecton) = React.useState(() => []);

  <div>
    <div className="flex justify-end px-4">
      <button className="btn btn-primary mt-2" onClick={_ => showEditorCB()}>
        {"Edit Checklist" |> str}
      </button>
    </div>
    {reviewChecklist
     |> Array.mapi((i, reviewChecklistItem) =>
          <div className="mt-2" key={i |> string_of_int}>
            <div className="text-lg font-semibold mt-2">
              {reviewChecklistItem |> ReviewChecklistItem.title |> str}
            </div>
            <div>
              {reviewChecklistItem
               |> ReviewChecklistItem.checklist
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
                        onChange={checkboxOnChange(i, index, setSelecton)}
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
    <button
      className="btn btn-primary mt-4 w-full"
      onClick={_ =>
        generateFeedback(reviewChecklist, selection, updateFeedbackCB)
      }>
      {"Generate Feedback" |> str}
    </button>
  </div>;
};
