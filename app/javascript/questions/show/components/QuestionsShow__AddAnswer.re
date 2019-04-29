[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

[@react.component]
let make = (~question) =>
  <div
    className="mt-4 max-w-md w-full flex mx-auto items-center justify-center relative shadow bg-white rounded-lg">
    <div className="flex w-full  py-4 px-4">
      <div className="w-full flex flex-col">
        <div>
          <input
            className="appearance-none block w-full bg-white text-grey-darker border border-grey-light rounded py-3 px-4 mb-6 leading-tight focus:outline-none focus:bg-white focus:border-grey"
          />
          <button
            className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 shadow rounded focus:outline-none">
            {"Add Your Answer" |> str}
          </button>
        </div>
      </div>
    </div>
  </div>;