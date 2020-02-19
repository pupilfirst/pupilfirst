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
      ~checklistVisible,
      ~targetId,
    ) => {
  let (checklistVisible, setChecklistVisible) =
    React.useState(() => checklistVisible);
  let reviewChecklistIsNotEmpty = reviewChecklist |> ArrayUtils.isNotEmpty;
  <div>
    <div>
      {switch (checklistVisible, reviewChecklistIsNotEmpty) {
       | (true, _)
       | (false, false) =>
         <CoursesReview__Checklist
           reviewChecklist
           updateFeedbackCB
           feedback
           updateReviewChecklistCB
           targetId
         />

       | (false, true) =>
         <div className="px-4 pt-4 md:px-6 pt-6">
           <button
             className="flex items-center bg-gray-100 border p-4 rounded-lg w-full text-left text-primary-500 font-semibold hover:bg-gray-200 hover:border-primary-300 focus:outline-none"
             onClick={_ => setChecklistVisible(_ => true)}>
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
      className="flex px-4 pt-4 md:px-6 md:pt-6 course-review__feedback-editor text-sm">
      <span className="mr-2 md:mr-3 pt-1">
        <Icon className="if i-comment-alt-regular text-gray-800 text-base" />
      </span>
      <div className="w-full" ariaLabel="feedback">
        <label
          className="inline-block tracking-wide text-gray-900 text-xs font-semibold mb-2">
          {label |> str}
        </label>
        <MarkdownEditor2
          onChange=updateFeedbackCB
          value=feedback
          profile=Markdown.Permissive
          maxLength=10000
        />
      </div>
    </div>
  </div>;
};
