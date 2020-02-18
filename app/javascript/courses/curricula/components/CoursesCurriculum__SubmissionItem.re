[@bs.config {jsx: 3}];

open CoursesCurriculum__Types;

let str = React.string;

[@react.component]
let make = (~authenticityToken, ~index, ~targetChecklistItem, ~response) => {
  let key = index |> string_of_int;
  <div>
    <label htmlFor="submission-description" className="font-semibold pl-1">
      {(targetChecklistItem |> TargetChecklistItem.title)
       ++ (
         targetChecklistItem |> TargetChecklistItem.optional
           ? " (optional)" : ""
       )
       |> str}
    </label>
    {switch (targetChecklistItem |> TargetChecklistItem.kind) {
     | Files =>
       <CoursesCurriculum__FileForm
         authenticityToken
         attachingCB={() => ()}
         attachFileCB={(id, filename) => ()}
         preview=true
       />
     | Link =>
       <input
         id="attachment_url"
         type_="text"
         placeholder="Type full URL starting with https://..."
         className="mt-2 cursor-pointer truncate h-10 border border-grey-400 flex px-4 items-center font-semibold rounded text-sm flex-grow mr-2"
       />
     | ShortText =>
       <input
         className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
         id={"short-text-" ++ key}
         type_="text"
         maxLength=250
       />
     | LongText =>
       <textarea
         id="submission-description"
         maxLength=1000
         className="h-40 w-full rounded-lg mt-4 p-4 border border-gray-400 focus:outline-none focus:border-gray-500 rounded-lg"
         placeholder="Describe your work, or leave notes to the reviewer here. If you are submitting a URL, or need to attach a file, use the controls below to add them."
       />
     | MultiChoice =>
       <input
         className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
         id={"short-text-" ++ key}
         type_="text"
         maxLength=250
       />
     | Statement =>
       <input
         className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
         id={"statement-" ++ key}
         type_="text"
         maxLength=250
       />
     }}
  </div>;
};
