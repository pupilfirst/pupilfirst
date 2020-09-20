let str = React.string;

open SchoolCommunities__IndexTypes;

type action =
  | UpdateNewCategoryName(string)
  | UpdateCategoryName(string, string)
  | RemoveCategory(string);

let topicsCountPillClass = category => {
  let color = Category.color(category);
  "bg-" ++ color ++ "-200 text-" ++ color ++ "-900";
};

[@react.component]
let make = (~community) => {
  let categories = Community.topicCategories(community);
  <div className="mx-8 pt-8">
    <h5 className="uppercase text-center border-b border-gray-400 pb-2">
      {"Categories in " ++ Community.name(community) |> str}
    </h5>
    {ReactUtils.nullIf(
       <div className="mb-2 flex flex-col">
         {categories
          |> Js.Array.map(category => {
               <SchoolCommunities__CategoryEditor
                 key={Category.id(category)}
                 category={Some(category)}
                 communityId={Community.id(community)}
               />
             })
          |> React.array}
       </div>,
       ArrayUtils.isEmpty(categories),
     )}
    {<SchoolCommunities__CategoryEditor
       category=None
       communityId={Community.id(community)}
     />}
  </div>;
};
