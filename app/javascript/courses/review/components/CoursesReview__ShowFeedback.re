[@bs.config {jsx: 3}];

open CoursesReview__Types;

let str = React.string;

type state = {
  saving: bool,
  newFeedback: string,
  showFeedbackEditor: bool,
};

let showFeedback = feedback =>
  feedback
  |> Array.mapi((index, f) =>
       <div key={index |> string_of_int} className="border-t p-4 md:p-6 flex">
         <div className="flex-shrink-0 w-10 h-10 bg-gray-300 rounded-full">
           <img src={f |> Feedback.coachAvatarUrl} />
         </div>
         <div className="flex-grow ml-3">
           <p className="text-xs leading-tight"> {"Feedback from:" |> str} </p>
           <div>
             <h4 className="font-semibold text-base inline-block">
               {f |> Feedback.coachName |> str}
             </h4>
             {
               switch (f |> Feedback.coachTitle) {
               | Some(title) =>
                 <span className="inline-block text-xs text-gray-700 ml-1">
                   {title |> str}
                 </span>
               | None => React.null
               }
             }
             <p className="text-xs leading-tight">
               {f |> Feedback.createdAtPretty |> str}
             </p>
           </div>
           <MarkdownBlock
             className="mt-3"
             profile=Markdown.Permissive
             markdown={f |> Feedback.value}
           />
         </div>
       </div>
     )
  |> React.array;

let updateFeedbackCB = (setState, newFeedback) =>
  setState(state => {...state, newFeedback});

[@react.component]
let make = (~authenticityToken, ~feedback, ~reviewed) => {
  let (state, setState) =
    React.useState(() =>
      {saving: false, newFeedback: "", showFeedbackEditor: false}
    );
  <div>
    {showFeedback(feedback)}
    {
      reviewed ?
        <div className="border-t">
          {
            state.showFeedbackEditor ?
              <div className="p-4 md:p-6">
                <CoursesReview__FeedbackEditor
                  feedback={state.newFeedback}
                  label="Add feedback"
                  updateFeedbackCB={updateFeedbackCB(setState)}
                />
              </div> :
              <div
                onClick={
                  _ => setState(state => {...state, showFeedbackEditor: true})
                }
                className="bg-gray-200 p-4 md:p-6 text-center font-bold cursor-pointer">
                {
                  (
                    switch (feedback) {
                    | [||] => "Add feedback"
                    | _ => "Add another feedback"
                    }
                  )
                  |> str
                }
              </div>
          }
        </div> :
        React.null
    }
  </div>;
};
