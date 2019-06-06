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

let newAttachmentForm =
  <div>
    <h6 className="pl-1 mt-4"> {"Attach files & links" |> str} </h6>
    <ul className="flex border-b mt-2">
      <li
        className="mr-1 cursor-pointer border-transparent border-l border-t border-r -mb-px rounded-t border-gray-400 bg-white">
        <a
          className="inline-block text-gray-800 hover:text-indigo-800 p-4 text-xs font-semibold">
          {"Upload File" |> str}
        </a>
      </li>
      <li
        className="mr-1 cursor-pointer border-transparent border-l border-t border-r -mb-px rounded-t">
        <a
          className="inline-block text-gray-800 p-4 hover:text-indigo-800 text-xs font-semibold">
          {"Add URL" |> str}
        </a>
      </li>
    </ul>
    <form>
      <input
        name="authenticity_token"
        type_="hidden"
        value="n3PCNUXI0JTS/4S9URK4uRc+b6f73Eoo0BSBLN29wVyO+DTlCX1rjxGeaVC3gHv9iSz1TdhDgaloy6Qn2a8UTg=="
      />
      <div
        className="bg-white p-4 pt-2 border-l border-r border-b rounded rounded-tl-none rounded-tr-none">
        <div className="flex items-center flex-wrap">
          <input
            className="hidden"
            name="attachment_file"
            required=true
            type_="file"
          />
          <label
            className="mt-2 cursor-pointer truncate h-10 border border-dashed flex px-4 items-center font-semibold rounded text-sm hover:bg-gray-400 flex-grow mr-2"
            htmlFor="file">
            <i className="fas fa-upload mr-2 text-gray-600 text-lg" />
            <span className="truncate">
              {"Choose file to upload" |> str}
            </span>
          </label>
          <button
            className="mt-2 bg-indigo-600 hover:bg-gray-500 text-white text-sm font-semibold py-2 px-6 focus:outline-none">
            {"Add Resource" |> str}
          </button>
        </div>
      </div>
    </form>
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
    newAttachmentForm
    <div className="flex mt-3 justify-end">
      <button
        className="btn btn-primary flex justify-center flex-grow md:flex-grow-0">
        <i className="fal fa-spinner-third fa-spin mr-2" />
        {"Submit" |> str}
      </button>
    </div>
  </div>;