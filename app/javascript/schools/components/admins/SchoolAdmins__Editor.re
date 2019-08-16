[@bs.config {jsx: 3}];

let str = React.string;

type editorAction =
  | ShowEditor(option(SchoolAdmin.t))
  | Hidden;

let renderAdmin = (admin, setEditorAction) =>
  <div
    key={admin |> SchoolAdmin.id}
    className="flex w-1/2 flex-shrink-0 mb-5 px-3">
    <div
      className="shadow bg-white rounded-lg flex w-full border border-transparent overflow-hidden hover:border-primary-400 hover:bg-gray-100">
      <a
        className="w-full cursor-pointer p-4"
        onClick={
          _event => {
            ReactEvent.Mouse.preventDefault(_event);
            setEditorAction(_ => ShowEditor(Some(admin)));
          }
        }>
        <div className="flex">
          <span className="mr-4 flex-shrink-0">
            <img
              className="w-10 h-10 rounded-full object-cover"
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
  <div className="flex flex-1 h-full overflow-y-scroll bg-gray-100">
    <div className="flex-1 flex flex-col">
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
          className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer">
          <i className="material-icons"> {"add_circle_outline" |> str} </i>
          <h5 className="font-semibold ml-2">
            {"Add New School Admin" |> str}
          </h5>
        </button>
      </div>
      <div className="px-6 pb-4 mt-5 flex">
        <div className="max-w-2xl w-full mx-auto">
          <div className="flex -mx-3 flex-wrap">
            {
              admins
              |> SchoolAdmin.sort
              |> List.map(admin => renderAdmin(admin, setEditorAction))
              |> Array.of_list
              |> ReasonReact.array
            }
          </div>
        </div>
      </div>
    </div>
  </div>;
};