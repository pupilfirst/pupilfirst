[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

open CoursesReview__Types;

type state = {
  reviewChecklist: array(ReviewChecklist.t),
  saving: bool,
  editMode: bool,
};

let str = React.string;

let showCheckList = checklist => {
  checklist
  |> Array.mapi((i, r) =>
       <div className="mt-2">
         <div className="text-lg font-semibold mt-2">
           {r |> ReviewChecklist.title |> str}
         </div>
         <div>
           {r
            |> ReviewChecklist.checklist
            |> Array.mapi((index, checklist) =>
                 <div className="px-2 mt-2">
                   <Checkbox
                     id={
                       "review_checkbox"
                       ++ (i |> string_of_int)
                       ++ (index |> string_of_int)
                     }
                     label={checklist |> ReviewChecklistResult.title}
                   />
                   <div className="pl-7">
                     {switch (checklist |> ReviewChecklistResult.feedback) {
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
  |> React.array;
};

let handleEmptyReviewCheckList = reviewChecklist => {
  reviewChecklist |> ArrayUtils.isEmpty
    ? ReviewChecklist.empty() : reviewChecklist;
};

[@react.component]
let make = (~reviewChecklist) => {
  let (state, setState) =
    React.useState(() =>
      {
        reviewChecklist: handleEmptyReviewCheckList(reviewChecklist),
        editMode: false,
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
      <div className="p-4">
        {switch (state.reviewChecklist) {
         | [||] => React.null
         | _ => showCheckList(state.reviewChecklist)
         }}
      </div>
    </div>
    <div className="btn btn-primary mt-4 w-full">
      {"Generate Feedback" |> str}
    </div>
  </div>;
};
