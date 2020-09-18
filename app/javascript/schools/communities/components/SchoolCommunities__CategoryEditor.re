let str = React.string;

open SchoolCommunities__IndexTypes;

type state = {newCategoryName: string};

type action =
  | UpdateName(string);

let topicsCountPillClass = category => {
  let color = Category.color(category);
  "bg-" ++ color ++ "-200 text-" ++ color ++ "-900";
};

let reducer = (state, action) => {
  switch (action) {
  | UpdateName(newCategoryName) => {...state, newCategoryName}
  };
};

[@react.component]
let make = (~categories) => {
  let (state, send) = React.useReducer(reducer, {newCategoryName: ""});
  <div className="mx-8 pt-8">
    <h5 className="uppercase text-center border-b border-gray-400 pb-2">
      {"Category Editor" |> str}
    </h5>
    {ReactUtils.nullIf(
       <div className="mb-2 flex flex-col">
         {categories
          |> Js.Array.map(category =>
               <div
                 key={category |> Category.id}
                 className="flex justify-between bg-gray-100 border-gray-400 shadow rounded-lg mt-3 p-2">
                 <div className="flex items-center">
                   <div className="mr-1 font-semibold px-2">
                     {category |> Category.name |> str}
                   </div>
                 </div>
                 <div>
                   <span
                     className={
                       "text-xs py-1 px-2 " ++ topicsCountPillClass(category)
                     }>
                     {string_of_int(Category.topicsCount(category))
                      ++ " topics"
                      |> str}
                   </span>
                   <button
                     className="py-1 px-2 h-8 text-gray-700 hover:text-gray-900 hover:bg-gray-100 border-l border-gray-400">
                     <i className="fas fa-trash-alt" />
                   </button>
                 </div>
               </div>
             )
          |> React.array}
       </div>,
       ArrayUtils.isEmpty(categories),
     )}
    <div className="flex mt-2">
      <input
        onChange={event => {
          let name = ReactEvent.Form.target(event)##value;
          send(UpdateName(name));
        }}
        value={state.newCategoryName}
        placeholder="Add new category"
        className="appearance-none h-10 block w-full text-gray-700 border rounded border-gray-400 py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
      />
      {let showButton = state.newCategoryName |> String.trim != "";
       showButton
         ? <button className="btn btn-success ml-2">
             {"Save Category" |> str}
           </button>
         : React.null}
    </div>
  </div>;
};
