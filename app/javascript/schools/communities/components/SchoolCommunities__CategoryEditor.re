open SchoolCommunities__IndexTypes;

let str = React.string;

type state = {
  categoryName: string,
  saving: bool,
  deleting: bool,
};

type action =
  | UpdateCategoryName(string);

let reducer = (state, action) => {
  switch (action) {
  | UpdateCategoryName(categoryName) => {...state, categoryName}
  };
};

module CreateCategoryQuery = [%graphql
  {|
  mutation CreateCategoryMutation($name: String!, $communityId: ID!) {
    createTopicCategory(name: $name, communityId: $communityId ) {
      id
    }
  }
|}
];

module DeleteCategoryQuery = [%graphql
  {|
  mutation DeleteCategoryMutation($id: ID!) {
    deleteTopicCategory(id: $id ) {
      success
    }
  }
|}
];

module UpdateCategoryQuery = [%graphql
  {|
  mutation UpdateCategoryMutation($name: String!, $id: ID!) {
    updateTopicCategory(id: $id, name: $name ) {
      success
    }
  }
|}
];

let topicsCountPillClass = category => {
  let color = Category.color(category);
  "bg-" ++ color ++ "-200 text-" ++ color ++ "-900";
};

let deleteCategory = (categoryId, event) => {
  ReactEvent.Mouse.preventDefault(event);

  DeleteCategoryQuery.make(~id=categoryId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##deleteTopicCategory##success
         ? Js.log("success") : Js.log("failure");
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(error => {
       Js.log(error);
       Notification.error(
         "Unexpected Error!",
         "Please reload the page and try again.",
       );
       Js.Promise.resolve();
     })
  |> ignore;
};

let updateCategory = (categoryId, newName, event) => {
  ReactEvent.Mouse.preventDefault(event);

  UpdateCategoryQuery.make(~id=categoryId, ~name=newName, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##updateTopicCategory##success
         ? Js.log("success") : Js.log("failure");
       Js.Promise.resolve();
     })
  |> Js.Promise.catch(error => {
       Js.log(error);
       Notification.error(
         "Unexpected Error!",
         "Please reload the page and try again.",
       );
       Js.Promise.resolve();
     })
  |> ignore;
};

let createCategory = (communityId, name, event) => {
  ReactEvent.Mouse.preventDefault(event);

  CreateCategoryQuery.make(~communityId, ~name, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       switch (response##createTopicCategory##id) {
       | Some(id) => Js.log(id)
       | None => Js.log("error")
       };

       Js.Promise.resolve();
     })
  |> Js.Promise.catch(error => {
       Js.log(error);
       Notification.error(
         "Unexpected Error!",
         "Please reload the page and try again.",
       );
       Js.Promise.resolve();
     })
  |> ignore;
};

[@react.component]
let make = (~category, ~communityId) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        categoryName:
          switch (category) {
          | Some(category) => Category.name(category)
          | None => ""
          },
        saving: false,
        deleting: false,
      },
    );
  switch (category) {
  | Some(category) =>
    let categoryId = Category.id(category);
    let presentCategoryName = Category.name(category);
    <div
      key=categoryId
      className="flex justify-between items-center bg-gray-100 border-gray-400 shadow rounded mt-3 px-2 py-1">
      <div className="flex-1 items-center mr-2">
        <input
          onChange={event => {
            let newName = ReactEvent.Form.target(event)##value;
            send(UpdateCategoryName(newName));
          }}
          value={state.categoryName}
          className="text-sm mr-1 font-semibold px-2 py-1 w-full"
        />
      </div>
      <div>
        {presentCategoryName == state.categoryName
           ? <span
               className={
                 "text-xs py-1 px-2 mr-2 " ++ topicsCountPillClass(category)
               }>
               {string_of_int(Category.topicsCount(category))
                ++ " topics"
                |> str}
             </span>
           : <button
               onClick={updateCategory(categoryId, state.categoryName)}
               className="btn btn-success mr-2 text-xs">
               {"Update Category" |> str}
             </button>}
        <button
          onClick={deleteCategory(categoryId)}
          className="text-xs py-1 px-2 h-8 text-gray-700 hover:text-gray-900 hover:bg-gray-100 border-l border-gray-400">
          <i className="fas fa-trash-alt" />
        </button>
      </div>
    </div>;
  | None =>
    <div className="flex mt-2">
      <input
        onChange={event => {
          let name = ReactEvent.Form.target(event)##value;
          send(UpdateCategoryName(name));
        }}
        value={state.categoryName}
        placeholder="Add new category"
        className="appearance-none h-10 block w-full text-gray-700 border rounded border-gray-400 py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
      />
      {let showButton = state.categoryName |> String.trim != "";
       showButton
         ? <button
             onClick={createCategory(communityId, state.categoryName)}
             className="btn btn-success ml-2 text-sm">
             {"Save Category" |> str}
           </button>
         : React.null}
    </div>
  };
};
