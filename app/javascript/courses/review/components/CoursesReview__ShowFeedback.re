[@bs.config {jsx: 3}];

open CoursesReview__Types;

let str = React.string;

type state = {
  saving: bool,
  newFeedback: string,
  showFeedbackEditor: bool,
};

module CreateFeedbackMutation = [%graphql
  {|
    mutation($submissionId: ID!, $feedback: String!) {
      createFeedback(submissionId: $submissionId, feedback: $feedback){
        success
      }
    }
  |}
];

let createFeedback =
    (authenticityToken, submissionId, feedback, setState, updateSubmissionCB) => {
  setState(state => {...state, saving: true});

  CreateFeedbackMutation.make(~submissionId, ~feedback, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##createFeedback##success
         ? {
           updateSubmissionCB(
             ~grades=[||],
             ~passed=None,
             ~newFeedback=Some(feedback),
           );
           setState(_ =>
             {saving: false, newFeedback: "", showFeedbackEditor: false}
           );
         }
         : setState(state => {...state, saving: false});
       Js.Promise.resolve();
     })
  |> ignore;
};

let showFeedback = feedback =>
  feedback
  |> Array.mapi((index, f) =>
       <div key={index |> string_of_int} className="border-t p-4 md:p-6">
         <div className="flex items-center">
           <div
             className="flex-shrink-0 w-12 h-12 bg-gray-300 rounded-full overflow-hidden mr-3 object-cover">
             <img src={f |> Feedback.coachAvatarUrl} />
           </div>
           <div>
             <p className="text-xs leading-tight">
               {"Feedback from:" |> str}
             </p>
             <div>
               <h4
                 className="font-semibold text-base leading-tight block md:inline-flex self-end">
                 {f |> Feedback.coachName |> str}
               </h4>
               {switch (f |> Feedback.coachTitle) {
                | Some(title) =>
                  <span
                    className="block md:inline-flex text-xs text-gray-800 md:ml-2 leading-tight self-end">
                    {"(" ++ title ++ ")" |> str}
                  </span>
                | None => React.null
                }}
             </div>
           </div>
         </div>
         <div className="md:ml-15">
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
let make =
    (
      ~authenticityToken,
      ~feedback,
      ~reviewed,
      ~submissionId,
      ~reviewChecklist,
      ~updateSubmissionCB,
    ) => {
  let (state, setState) =
    React.useState(() =>
      {saving: false, newFeedback: "", showFeedbackEditor: false}
    );
  <div ariaLabel="feedback-section">
    {showFeedback(feedback)}
    {reviewed
       ? <div className="border-t bg-white rounded-b-lg">
           {state.showFeedbackEditor
              ? <div className="p-4 md:p-6">
                  <DisablingCover disabled={state.saving}>
                    <CoursesReview__FeedbackEditor
                      feedback={state.newFeedback}
                      label="Add feedback"
                      updateFeedbackCB={updateFeedbackCB(setState)}
                      reviewChecklist
                    />
                  </DisablingCover>
                  <button
                    disabled={state.newFeedback == "" || state.saving}
                    className="btn btn-success btn-large w-full border border-green-600 mt-4"
                    onClick={_ =>
                      createFeedback(
                        authenticityToken,
                        submissionId,
                        state.newFeedback,
                        setState,
                        updateSubmissionCB,
                      )
                    }>
                    {"Share Feedback" |> str}
                  </button>
                </div>
              : <div
                  className="bg-gray-200 px-3 py-5 shadow-inner rounded-b-lg text-center">
                  <button
                    onClick={_ =>
                      setState(state => {...state, showFeedbackEditor: true})
                    }
                    className="btn btn-primary-ghost cursor-pointer shadow hover:shadow-lg w-full md:w-auto">
                    {(
                       switch (feedback) {
                       | [||] => "Add feedback"
                       | _ => "Add another feedback"
                       }
                     )
                     |> str}
                  </button>
                </div>}
         </div>
       : React.null}
  </div>;
};
