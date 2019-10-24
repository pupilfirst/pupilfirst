[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__FeedbackEditor.css")|}];

let str = React.string;

[@react.component]
let make =
    (
      ~feedback,
      ~updateFeedbackCB,
      ~label,
      ~reviewChecklist,
      ~updateReviewChecklistCB,
      ~showChecklist,
      ~targetId,
    ) => {
  let (showChecklist, setShowCHecklist) = React.useState(() => showChecklist);
  <div>
    <div>
      {switch (showChecklist, reviewChecklist |> ArrayUtils.isEmpty) {
       | (false, true)
       | (true, _) =>
         <CoursesReview__Checklist
           reviewChecklist
           updateFeedbackCB
           feedback
           updateReviewChecklistCB
           targetId
         />

       | (false, false) =>
         <div className="px-4 pt-4 md:px-6 pt-6">
           <button
             className="flex items-center bg-gray-100 border p-4 rounded-lg w-full text-left text-primary-500 font-semibold hover:bg-gray-200 hover:border-primary-300 focus:outline-none"
             onClick={_ => setShowCHecklist(_ => true)}>
             <span
               className="inline-flex w-10 h-10 border border-white items-center justify-center rounded-full bg-primary-100 text-primary-500">
               <i className="fas fa-list" />
             </span>
             <span className="ml-3"> {"Show Review Checklist" |> str} </span>
           </button>
         </div>
       }}
    </div>
    <div
      className="px-4 pt-4 md:px-6 md:pt-6 course-review__feedback-editor text-sm">
      <MarkdownEditor
        updateMarkdownCB=updateFeedbackCB
        value=feedback
        label
        profile=Markdown.Permissive
        defaultView=MarkdownEditor.Edit
        maxLength=10000
      />
    </div>
  </div>;
};
