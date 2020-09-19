let str = React.string;

open SchoolCommunities__IndexTypes;

type state = {
  newCategoryName: string,
  categories: array(Category.t),
};

type action =
  | UpdateNewCategoryName(string)
  | UpdateCategoryName(string, string)
  | RemoveCategory(string);

let topicsCountPillClass = category => {
  let color = Category.color(category);
  "bg-" ++ color ++ "-200 text-" ++ color ++ "-900";
};

let reducer = (state, action) => {
  switch (action) {
  | UpdateNewCategoryName(name) => {...state, newCategoryName: name}
  | UpdateCategoryName(id, name) => {
      ...state,
      categories:
        state.categories
        |> Array.map(c =>
             Category.id(c) == id ? Category.updateName(name, c) : c
           ),
    }
  | RemoveCategory(id) => {
      ...state,
      categories:
        state.categories |> Js.Array.filter(c => Category.id(c) != id),
    }
  };
};

[@react.component]
let make = (~categories, ~community) => {
  let (state, send) =
    React.useReducer(reducer, {newCategoryName: "", categories});
  <div className="mx-8 pt-8">
    <h5 className="uppercase text-center border-b border-gray-400 pb-2">
      {"Categories in " ++ Community.name(community) |> str}
    </h5>
    {ReactUtils.nullIf(
       <div className="mb-2 flex flex-col">
         {state.categories
          |> Js.Array.map(category => {
               <SchoolCommunities__CategoryEditor
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
