[@bs.config {jsx: 3}];

let str = React.string;

open SchoolCommunities__IndexTypes;

[@react.component]
let make = (~authenticityToken, ~communities, ~courses) => {
  let (drawerVisible, setDrawerVisible) = React.useState(() => false);

  <div className="flex-1 flex flex-col">
    <SchoolAdmin__EditorDrawer
      closeDrawerCB={() => setDrawerVisible(_ => false)}>
      <SchoolCommunities__Editor authenticityToken courses />
    </SchoolAdmin__EditorDrawer>
    <div className="flex px-6 py-2 items-center justify-between">
      <button
        className="max-w-md w-full flex mx-auto items-center justify-center relative bg-grey-lighter hover:bg-grey-light hover:shadow-md border-2 border-dashed p-6 rounded-lg mt-12 cursor-pointer">
        <i className="material-icons"> {"add_circle_outline" |> str} </i>
        <h4 className="font-semibold ml-2"> {"Add New Community" |> str} </h4>
      </button>
    </div>
    <div className="px-6 pb-4 mt-5 flex flex-1">
      <div className="max-w-md w-full mx-auto relative">
        {
          communities
          |> List.map(community =>
               <div
                 key={community |> Community.id}
                 className="flex items-center shadow bg-white rounded-lg mb-4">
                 <div className="course-faculty__list-item flex w-full">
                   <div
                     className="course-faculty__list-item-details flex flex-1 items-center justify-between cursor-pointer py-4 px-4 hover:bg-grey-lighter">
                     <div className="flex">
                       <div className="text-sm">
                         <p className="text-black font-semibold">
                           {community |> Community.name |> str}
                         </p>
                       </div>
                     </div>
                     <div
                       className="w-7 course-faculty__list-item-edit flex items-center justify-center invisible"
                     />
                   </div>
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