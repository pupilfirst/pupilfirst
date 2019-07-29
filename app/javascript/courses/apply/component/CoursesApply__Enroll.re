[@bs.config {jsx: 3}];
let str = React.string;

module Applicant = CoursesApply__Applicant;

let buttonText = (name, saving) =>
  switch (saving, name == "") {
  | (true, false | true) => "Saving"
  | (false, true) => "Enter your Name"
  | (false, false) => "Enroll"
  };

[@react.component]
let make = (~authenticityToken, ~courseName, ~applicant) => {
  let (name, setName) = React.useState(() => "");
  let (password, setPassword) = React.useState(() => "");
  let (saving, setSaving) = React.useState(() => false);
  <div className="flex flex-col">
    <h4 className="font-bold">
      {"Enroll to " ++ courseName ++ " course" |> str}
    </h4>
    <div className="font-bold">
      {"Email: " ++ (applicant |> Applicant.email) |> str}
    </div>
    <div className="w-full mt-4">
      <label
        htmlFor="name"
        className="inline-block tracking-wide text-gray-800 text-xs font-semibold">
        {"Name" |> str}
      </label>
      <input
        id="name"
        className="appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
        type_="text"
        value=name
        disabled=saving
        onChange={event => setName(ReactEvent.Form.target(event)##value)}
        placeholder="John Doe"
      />
      <label
        htmlFor="password"
        className="inline-block tracking-wide text-gray-800 text-xs font-semibold">
        {"Password (optional)" |> str}
      </label>
      <input
        id="password"
        className="appearance-none h-10 mt-1 block w-full text-gray-800 border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
        type_="password"
        value=password
        disabled=saving
        onChange={event => setPassword(ReactEvent.Form.target(event)##value)}
        placeholder="Add a strong password"
      />
    </div>
    <button
      disabled={name == "" || saving}
      className="btn btn-primary justify-center shadow-lg mt-6">
      {
        saving ?
          <FaIcon classes="fal fa-spinner-third fa-spin mr-2" /> :
          ReasonReact.null
      }
      <span> {buttonText(name, saving) |> str} </span>
    </button>
  </div>;
};
