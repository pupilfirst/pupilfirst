[@bs.config {jsx: 3}];

let str = React.string;

type editorAction =
  | ShowEditor(option(SchoolAdmin.t))
  | Hidden;

type state = {
  editorAction,
  admins: array(SchoolAdmin.t),
};

let renderAdmin = (admin, setState) =>
  <div
    key={(admin |> SchoolAdmin.id) ++ (admin |> SchoolAdmin.name)}
    className="flex w-1/2 flex-shrink-0 mb-5 px-3">
    <div
      className="shadow bg-white rounded-lg flex w-full border border-transparent overflow-hidden hover:border-primary-400 hover:bg-gray-100">
      <a
        className="w-full cursor-pointer p-4"
        onClick={_event => {
          ReactEvent.Mouse.preventDefault(_event);
          setState(state =>
            {...state, editorAction: ShowEditor(Some(admin))}
          );
        }}>
        <div className="flex">
          <span className="mr-4 flex-shrink-0">
            {switch (admin |> SchoolAdmin.avatarUrl) {
             | Some(avatarUrl) =>
               <img
                 className="w-10 h-10 rounded-full object-cover"
                 src=avatarUrl
               />
             | None =>
               <Avatar
                 name={admin |> SchoolAdmin.name}
                 className="w-10 h-10 rounded-full"
               />
             }}
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

let handleUpdate = (setState, admin) =>
  setState(state =>
    {admins: state.admins |> SchoolAdmin.update(admin), editorAction: Hidden}
  );

[@react.component]
let make = (~currentSchoolAdminId, ~admins) => {
  let (state, setState) =
    React.useState(() => {editorAction: Hidden, admins});
  <div className="flex flex-1 h-full overflow-y-scroll bg-gray-100">
    <div className="flex-1 flex flex-col">
      {switch (state.editorAction) {
       | Hidden => React.null
       | ShowEditor(admin) =>
         <SchoolAdmin__EditorDrawer
           closeDrawerCB={_ =>
             setState(state => {...state, editorAction: Hidden})
           }>
           <SchoolAdmins__Form admin updateCB={handleUpdate(setState)} />
         </SchoolAdmin__EditorDrawer>
       }}
      <div className="flex px-6 py-2 items-center justify-between">
        <button
          onClick={_ =>
            setState(state => {...state, editorAction: ShowEditor(None)})
          }
          className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer">
          <i className="fas fa-plus-circle" />
          <h5 className="font-semibold ml-2">
            {"Add New School Admin" |> str}
          </h5>
        </button>
      </div>
      <div className="px-6 pb-4 mt-5 flex">
        <div className="max-w-2xl w-full mx-auto">
          <div className="flex -mx-3 flex-wrap">
            {state.admins
             |> SchoolAdmin.sort
             |> Array.map(admin => renderAdmin(admin, setState))
             |> ReasonReact.array}
          </div>
        </div>
      </div>
    </div>
  </div>;
};
