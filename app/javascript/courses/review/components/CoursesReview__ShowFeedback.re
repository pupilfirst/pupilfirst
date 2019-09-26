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
         <div
           className="flex-shrink-0 w-10 h-10 bg-gray-300 rounded-full overflow-hidden">
           <img src={f |> Feedback.coachAvatarUrl} />
         </div>
         <div className="flex-grow ml-3">
           <p className="text-xs leading-tight"> {"Feedback from:" |> str} </p>
           <div className="flex flex-col md:flex-row md:items-center">
             <h4 className="font-semibold text-base inline-block">
               {f |> Feedback.coachName |> str}
             </h4>
             {
               switch (f |> Feedback.coachTitle) {
               | Some(title) =>
                 <span
                   className="inline-block text-xs text-gray-800 md:ml-2 pt-1 md:pt-0 leading-tight">
                   {"(" ++ title ++ ")" |> str}
                 </span>
               | None => React.null
               }
             }
           </div>
           <p
             className="text-xs leading-tight font-semibold inline-block p-1 bg-gray-200 rounded mt-4">
             {f |> Feedback.createdAtPretty |> str}
           </p>
           <MarkdownBlock
             className="pt-1"
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
        <div className="border-t bg-white rounded-b-lg">
          {
            state.showFeedbackEditor ?
              <div className="p-4 md:p-6">
                <CoursesReview__FeedbackEditor
                  feedback={state.newFeedback}
                  label="Add feedback"
                  updateFeedbackCB={updateFeedbackCB(setState)}
                />
                <button
                  disabled={state.newFeedback == ""}
                  className="btn btn-success btn-large w-full border border-green-600 mt-4">
                  {"Share Feedback" |> str}
                </button>
              </div> :
              <div
                className="bg-gray-200 px-3 py-5 shadow-inner rounded-b-lg text-center">
                <div
                  onClick={
                    _ =>
                      setState(state => {...state, showFeedbackEditor: true})
                  }
                  className="btn btn-primary-ghost cursor-pointer shadow hover:shadow-lg w-full md:w-auto">
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
              </div>
          }
        </div> :
        React.null
    }
  </div>;
};
