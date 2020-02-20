let str = React.string;

open SchoolCommunities__IndexTypes;

module CreateCommunityQuery = [%graphql
  {|
  mutation($name: String!, $targetLinkable: Boolean!, $courseIds: [ID!]!) {
    createCommunity(name: $name, targetLinkable: $targetLinkable, courseIds: $courseIds) @bsVariant {
      communityId
      errors
    }
  }
|}
];

module UpdateCommunityQuery = [%graphql
  {|
  mutation($id: ID!, $name: String!, $targetLinkable: Boolean!, $courseIds: [ID!]!) {
    updateCommunity(id: $id, name: $name, targetLinkable: $targetLinkable, courseIds: $courseIds) @bsVariant {
      communityId
      errors
    }
  }
|}
];

module CreateCommunityError = {
  type t = [ | `InvalidLengthName | `IncorrectCourseIds];

  let notification = error =>
    switch (error) {
    | `InvalidLengthName => (
        "InvalidLengthName",
        "Course name should be between 1 and 50 characters long.",
      )
    | `IncorrectCourseIds => (
        "IncorrectCourseIds",
        "Could not find courses with the supplied IDs.",
      )
    };
};

module UpdateCommunityError = {
  type t = [
    | `InvalidLengthName
    | `IncorrectCourseIds
    | `IncorrectCommunityId
  ];

  let notification = error =>
    switch (error) {
    | `InvalidLengthName => (
        "InvalidLengthName",
        "Course name should be between 1 and 50 characters long.",
      )
    | `IncorrectCourseIds => (
        "IncorrectCourseIds",
        "Could not find courses with the supplied IDs.",
      )
    | `IncorrectCommunityId => (
        "IncorrectCommunityId",
        "Community does not exist.",
      )
    };
};

module CreateCommunityErrorHandler =
  GraphqlErrorHandler.Make(CreateCommunityError);

module UpdateCommunityErrorHandler =
  GraphqlErrorHandler.Make(UpdateCommunityError);

let handleConnections = (communityId, connections, courseIds) => {
  let oldConnections =
    connections
    |> List.filter(connection =>
         connection |> Connection.communityId != communityId
       );
  let newConnectionsForCommunity =
    courseIds
    |> Array.map(courseId => Connection.create(communityId, courseId))
    |> Array.to_list;
  oldConnections |> List.append(newConnectionsForCommunity);
};

let handleQuery =
    (
      name,
      targetLinkable,
      courseIds,
      setSaving,
      community,
      addCommunityCB,
      updateCommunitiesCB,
      connections,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  if (name != "") {
    setSaving(_ => true);

    switch (community) {
    | Some(community) =>
      UpdateCommunityQuery.make(
        ~id=community |> Community.id,
        ~name,
        ~targetLinkable,
        ~courseIds,
        (),
      )
      |> GraphqlQuery.sendQuery
      |> Js.Promise.then_(response =>
           switch (response##updateCommunity) {
           | `CommunityId(communityId) =>
             setSaving(_ => false);
             updateCommunitiesCB(
               Community.create(communityId, name, targetLinkable),
               handleConnections(communityId, connections, courseIds),
             );
             Notification.success(
               "Success",
               "Community updated successfully.",
             );
             Js.Promise.resolve();
           | `Errors(errors) =>
             Js.Promise.reject(UpdateCommunityErrorHandler.Errors(errors))
           }
         )
      |> UpdateCommunityErrorHandler.catch(() => setSaving(_ => false))
      |> ignore
    | None =>
      CreateCommunityQuery.make(~name, ~targetLinkable, ~courseIds, ())
      |> GraphqlQuery.sendQuery
      |> Js.Promise.then_(response =>
           switch (response##createCommunity) {
           | `CommunityId(communityId) =>
             setSaving(_ => false);
             addCommunityCB(
               Community.create(communityId, name, targetLinkable),
               handleConnections(communityId, connections, courseIds),
             );
             Notification.success(
               "Success",
               "Community created successfully.",
             );
             Js.Promise.resolve();
           | `Errors(errors) =>
             Js.Promise.reject(CreateCommunityErrorHandler.Errors(errors))
           }
         )
      |> CreateCommunityErrorHandler.catch(() => setSaving(_ => false))
      |> ignore
    };
  } else {
    Notification.error("Empty", "Answer cant be blank");
  };
};

let booleanButtonClasses = bool => {
  let classes = "toggle-button__button";
  classes ++ (bool ? " toggle-button__button--active" : "");
};

let communityCourseIds = courseState =>
  courseState
  |> List.filter(((_, _, selected)) => selected)
  |> List.map(((id, _, _)) => id |> string_of_int)
  |> Array.of_list;

[@react.component]
let make =
    (
      ~courses,
      ~community,
      ~connections,
      ~addCommunityCB,
      ~updateCommunitiesCB,
    ) => {
  let (saving, setSaving) = React.useState(() => false);
  let (dirty, setDirty) = React.useState(() => false);
  let (name, setName) =
    React.useState(() =>
      switch (community) {
      | Some(community) => community |> Community.name
      | None => ""
      }
    );
  let (targetLinkable, setTargetLinkable) =
    React.useState(() =>
      switch (community) {
      | Some(community) => community |> Community.targetLinkable
      | None => false
      }
    );
  let (courseState, setCourseState) =
    React.useState(() =>
      courses
      |> List.map(course =>
           (
             course |> Course.id |> int_of_string,
             (course |> Course.name) ++ " Course",
             switch (community) {
             | Some(community) =>
               connections
               |> List.filter(connection =>
                    connection
                    |> Connection.communityId == (community |> Community.id)
                    && connection
                    |> Connection.courseId == (course |> Course.id)
                  )
               |> ListUtils.isNotEmpty
             | None => false
             },
           )
         )
    );

  let selectCB = (id, name, selected) => {
    let oldCourses =
      courseState |> List.filter(((courseId, _, _)) => courseId !== id);
    setCourseState(_ => [(id, name, selected), ...oldCourses]);
    setDirty(_ => true);
  };

  let saveDisabled = name == "" || !dirty;

  <div className="mx-8 pt-8">
    <h5 className="uppercase text-center border-b border-gray-400 pb-2">
      {"Community Editor" |> str}
    </h5>
    <DisablingCover disabled=saving>
      <div key="communities-editor" className="mt-3">
        <div className="mt-2">
          <label
            className="inline-block tracking-wide text-gray-700 text-xs font-semibold"
            htmlFor="communities-editor__name">
            {"What do you want to call this community?" |> str}
          </label>
          <input
            placeholder="This community needs a name!"
            value=name
            onChange={event => {
              setName(ReactEvent.Form.target(event)##value);
              setDirty(_ => true);
            }}
            id="communities-editor__name"
            className="appearance-none h-10 mt-2 block w-full text-gray-700 border border-gray-400 rounded py-2 px-4 text-sm bg-gray-100 hover:bg-gray-200 focus:outline-none focus:bg-white focus:border-primary-400"
          />
          <School__InputGroupError
            message="is not a valid name"
            active={dirty ? name == "" : false}
          />
        </div>
        <div className="flex items-center mt-6">
          <label
            className="inline-block tracking-wide text-gray-700 text-xs font-semibold"
            htmlFor="communities-editor__course-list">
            {"Should students be allowed to discuss targets in this community?"
             |> str}
          </label>
          <div
            className="flex toggle-button__group flex-no-shrink rounded-lg overflow-hidden ml-2">
            <button
              onClick={_ => {
                setDirty(_ => true);
                setTargetLinkable(_ => true);
              }}
              className={booleanButtonClasses(targetLinkable == true)}>
              {"Yes" |> str}
            </button>
            <button
              onClick={_ => {
                setDirty(_ => true);
                setTargetLinkable(_ => false);
              }}
              className={booleanButtonClasses(targetLinkable == false)}>
              {"No" |> str}
            </button>
          </div>
        </div>
        <div className="mt-4">
          <label
            className="inline-block tracking-wide text-gray-700 text-xs font-semibold mb-2"
            htmlFor="communities-editor__course-targetLinkable">
            {"Give access to students from:" |> str}
          </label>
          <School__SelectBox
            items={courseState |> School__SelectBox.convertOldItems}
            selectCB={School__SelectBox.convertOldCallback(selectCB)}
          />
        </div>
      </div>
      <button
        disabled=saveDisabled
        onClick={handleQuery(
          name,
          targetLinkable,
          communityCourseIds(courseState),
          setSaving,
          community,
          addCommunityCB,
          updateCommunitiesCB,
          connections,
        )}
        key="communities-editor__update-button"
        className="w-full btn btn-large btn-primary mt-3">
        {(
           switch (community) {
           | Some(_) => "Update Community"
           | None => "Create a new community"
           }
         )
         |> str}
      </button>
    </DisablingCover>
    <div className="mt-3 mb-3 text-xs">
      <span className="leading-normal">
        <strong> {"Note:" |> str} </strong>
        {" Coaches in your school have access to all communities." |> str}
      </span>
    </div>
  </div>;
};
