[@bs.config {jsx: 3}];

let str = React.string;

type editorAction =
  | ShowEditor(option(SchoolAdmin.t))
  | Hidden;

[@react.component]
let make = (~authenticityToken, ~admin) => {
  let (saving, setSaving) = React.useState(() => false);
  let (name, setName) =
    React.useState(() =>
      switch (admin) {
      | Some(admin) => admin |> SchoolAdmin.name
      | None => ""
      }
    );
  let (email, setEmail) =
    React.useState(() =>
      switch (admin) {
      | Some(admin) => admin |> SchoolAdmin.email
      | None => ""
      }
    );
  <div className="w-full">
    <div className="mx-auto bg-white">
      <div className="flex items-centre font-bold py-6 pl-16 mb-4 bg-gray-200">
        {
          (
            switch (admin) {
            | Some(_) => "Update school admin"
            | None => "Add new school admin"
            }
          )
          |> str
        }
      </div>
      <div className="max-w-2xl p-6 mx-auto">
        <div>
          <label
            className="inline-block tracking-wide text-xs font-semibold mb-2"
            htmlFor="name">
            {"Name" |> str}
          </label>
          <span> {"*" |> str} </span>
          <input
            value=name
            onChange={event => setName(ReactEvent.Form.target(event)##value)}
            className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
            id="name"
            type_="text"
            placeholder="add name here"
          />
          <div className="mt-5">
            <label
              className="inline-block tracking-wide text-xs font-semibold mb-2"
              htmlFor="email">
              {"Email" |> str}
            </label>
            <span> {"*" |> str} </span>
            <input
              value=email
              onChange={
                event => setEmail(ReactEvent.Form.target(event)##value)
              }
              className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
              id="email"
              type_="email"
              placeholder="Add email here"
            />
          </div>
          <div className="w-auto mt-8">
            <button className="w-full btn btn-large btn-primary">
              {"Update Student" |> str}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>;
};
