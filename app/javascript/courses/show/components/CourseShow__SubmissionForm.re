[@bs.config {jsx: 3}];

let str = React.string;

let attachments =
  <div className="flex flex-wrap">
    <span
      className="mt-2 mr-2 flex items-center border-2 border-blue-200 bg-blue-200 rounded-lg">
      <span className="flex p-2 bg-blue-200 cursor-pointer">
        <i className="fas fa-times" />
      </span>
      <span className="bg-blue-100 rounded px-2 py-1 truncate rounded-lg">
        <span className="text-xs font-semibold text-primary-600">
          {"https://www.example.com/a-long-url" |> str}
        </span>
      </span>
    </span>
    <span
      className="mt-2 mr-2 flex items-center border-2 border-primary-200 bg-primary-200 rounded-lg">
      <span className="flex p-2 bg-primary-200 cursor-pointer">
        <i className="fas fa-times" />
      </span>
      <span className="bg-primary-100 rounded px-2 py-1 truncate rounded-lg">
        <span className="text-xs font-semibold text-primary-600">
          {"filename.pdf" |> str}
        </span>
      </span>
    </span>
  </div>;

[@react.component]
let make = (~target) =>
  <div className="bg-gray-200 pt-6 px-4 pb-2 mt-4 shadow rounded-lg">
    <h5 className="pl-1"> {"Work on your submission" |> str} </h5>
    <textarea
      className="w-full rounded-lg mt-4 p-4 border rounded-lg"
      placeholder="Start typing! We'll auto-save your work periodically as a draft, and you can submit when you're ready to do so."
    />
    attachments
    <CourseShow__NewAttachment />
    <div className="flex mt-3 justify-end">
      <button
        className="btn btn-primary flex justify-center flex-grow md:flex-grow-0">
        <i className="fal fa-spinner-third fa-spin mr-2" />
        {"Submit" |> str}
      </button>
    </div>
  </div>;