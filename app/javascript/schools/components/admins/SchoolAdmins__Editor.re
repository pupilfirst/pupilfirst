[@bs.config {jsx: 3}];

let str = React.string;

type editorAction =
  | ShowEditor(option(SchoolAdmin.t))
  | Hidden;

let renderAdmin = (admin, setEditorAction) =>
  <div key={admin |> SchoolAdmin.id} className="w-1/2 px-2">
    <div
      className="flex shadow bg-white rounded-lg mb-4 overflow-hidden hover:bg-gray-100 p-2">
      <a
        className="w-full cursor-pointer"
        onClick={
          _event => {
            ReactEvent.Mouse.preventDefault(_event);
            setEditorAction(_ => ShowEditor(Some(admin)));
          }
        }>
        <div className="flex p-2">
          <span>
            <img
              className="w-10 h-10 rounded-full mr-4 object-cover"
              src={admin |> SchoolAdmin.avatarUrl}
            />
          </span>
          <div className="flex flex-col">
            <span className="text-black font-semibold text-sm">
              {admin |> SchoolAdmin.name |> str}
            </span>
            <span className="text-black font-normal text-xs">
              {admin |> SchoolAdmin.email |> str}
            </span>
          </div>
        </div>
      </a>
    </div>
  </div>;

let handleUpdate = (admin, admins, setAdmins, setEditorAction) => {
  setAdmins(_ => admins |> SchoolAdmin.update(admin));
  setEditorAction(_ => Hidden);
};

[@react.component]
let make = (~authenticityToken, ~admins) => {
  let (editorAction, setEditorAction) = React.useState(() => Hidden);
  let (admins, setAdmins) = React.useState(() => admins);
  let updateCB = admin =>
    handleUpdate(admin, admins, setAdmins, setEditorAction);

  <div className="flex-1 flex flex-col overflow-x-scroll">
    {
      switch (editorAction) {
      | Hidden => React.null
      | ShowEditor(admin) =>
        <SchoolAdmin__EditorDrawer
          closeDrawerCB=(() => setEditorAction(_ => Hidden))>
          <SchoolAdmins__Form authenticityToken admin updateCB />
        </SchoolAdmin__EditorDrawer>
      }
    }
    <div className="flex px-6 py-2 items-center justify-between">
      <button
        onClick={_ => setEditorAction(_ => ShowEditor(None))}
        className="max-w-3xl w-full flex mx-auto items-center justify-center relative bg-gray-200 hover:bg-gray-400 hover:shadow-md border-2 border-dashed p-6 rounded-lg mt-12 cursor-pointer">
        <i className="material-icons"> {"add_circle_outline" |> str} </i>
        <h4 className="font-semibold ml-2">
          {"Add New School Admin" |> str}
        </h4>
      </button>
    </div>
    <div className="px-6 pb-4 mt-5 flex flex-1">
      <div className="max-w-3xl w-full mx-auto flex flex-wrap">
        {
          admins
          |> List.map(admin => renderAdmin(admin, setEditorAction))
          |> Array.of_list
          |> ReasonReact.array
        }
      </div>
    </div>
  </div>;
};
