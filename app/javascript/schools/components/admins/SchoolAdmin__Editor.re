[@bs.config {jsx: 3}];

let str = React.string;

type editorAction =
  | ShowEditor(option(SchoolAdmin.t))
  | Hidden;

[@react.component]
let make = (~authenticityToken, ~admins) => {
  let (editorAction, setEditorAction) = React.useState(() => Hidden);
  <div className="flex-1 flex flex-col">
    {
      switch (editorAction) {
      | Hidden => React.null
      | ShowEditor(admin) =>
        <SchoolAdmin__EditorDrawer
          closeDrawerCB=(() => setEditorAction(_ => Hidden))>
          <div> {"Halo" |> str} </div>
          {
            switch (admin) {
            | Some(admin) => <div> {admin |> SchoolAdmin.name |> str} </div>
            | None => React.null
            }
          }
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
      <div className="max-w-3xl w-full mx-auto relative">
        {
          admins
          |> List.map(admin =>
               <div
                 key={admin |> SchoolAdmin.id}
                 className="flex items-center shadow bg-white rounded-lg mb-4">
                 <div
                   className="course-faculty__list-item flex w-full items-center">
                   <a
                     onClick={
                       _event => {
                         ReactEvent.Mouse.preventDefault(_event);
                         setEditorAction(_ => ShowEditor(Some(admin)));
                       }
                     }
                     className="course-faculty__list-item-details flex flex-1 items-center justify-between cursor-pointer py-4 px-4 hover:bg-gray-100">
                     <div className="flex">
                       <div className="text-sm justify-between">
                         <span className="text-black font-semibold">
                           {admin |> SchoolAdmin.name |> str}
                         </span>
                       </div>
                     </div>
                   </a>
                 </div>
               </div>
             )
          |> Array.of_list
          |> ReasonReact.array
        }
      </div>
    </div>
  </div>;
};
