[@bs.config {jsx: 3}];

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
        "The list of courses selected are incorrect",
      )
    | `IncorrectCourseIds => (
        "IncorrectCourseIds",
        "Supplied description must be greater than 1 characters in length",
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
        "The list of courses selected are incorrect",
      )
    | `IncorrectCourseIds => (
        "IncorrectCourseIds",
        "Supplied description must be greater than 1 characters in length",
      )
    | `IncorrectCommunityId => (
        "IncorrectCommunityId",
        "Community does not exist",
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
      authenticityToken,
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
      |> GraphqlQuery.sendQuery(authenticityToken)
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
      |> GraphqlQuery.sendQuery(authenticityToken)
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
  classes ++ (bool ? " toggle-button__button--active" : " text-grey-dark");
};

let communityCourseIds = courseState =>
  courseState
  |> List.filter(((_, _, selected)) => selected)
  |> List.map(((id, _, _)) => id |> string_of_int)
  |> Array.of_list;

[@react.component]
let make =
    (
      ~authenticityToken,
      ~courses,
      ~community,
      ~connections,
      ~addCommunityCB,
      ~updateCommunitiesCB,
    ) => {
  let (saving, setSaving) = React.useState(() => false);
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
             course |> Course.name,
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

  let multiSelectCB = (id, name, selected) => {
    let oldCourses =
      courseState |> List.filter(((courseId, _, _)) => courseId !== id);
    setCourseState(_ => [(id, name, selected), ...oldCourses]);
  };

  <div className="mx-8 pt-8">
    <h5 className="uppercase text-center border-b border-grey-light pb-2">
      {"Community Editor" |> str}
    </h5>
    <DisablingCover disabled=saving>
      <div key="communities-editor" className="mt-3">
        <label
          className="inline-block tracking-wide text-grey-darker text-xs font-semibold mt-4"
          htmlFor="communities-editor__name">
          {"Name" |> str}
        </label>
        <input
          value=name
          onChange={event => setName(ReactEvent.Form.target(event)##value)}
          id="communities-editor__name"
          className="appearance-none h-10 mt-2 block w-full text-grey-darker border border-grey-light rounded py-2 px-4 text-sm bg-grey-lightest hover:bg-grey-lighter focus:outline-none focus:bg-white focus:border-primary-light"
        />
        <label
          className="inline-block tracking-wide text-grey-darker text-xs font-semibold mt-4"
          htmlFor="communities-editor__course-list">
          {
            "Allow students to ask questions about targets in this community?"
            |> str
          }
        </label>
        <div
          className="flex toggle-button__group flex-no-shrink rounded-lg overflow-hidden border mt-2">
          <button
            onClick={_ => setTargetLinkable(_ => true)}
            className={booleanButtonClasses(targetLinkable == true)}>
            {"Yes" |> str}
          </button>
          <button
            onClick={_ => setTargetLinkable(_ => false)}
            className={booleanButtonClasses(targetLinkable == false)}>
            {"No" |> str}
          </button>
        </div>
        <label
          className="inline-block tracking-wide text-grey-darker text-xs font-semibold mt-4 mb-2"
          htmlFor="communities-editor__course-targetLinkable">
          {"Course" |> str}
        </label>
        <School__SelectBox items=courseState multiSelectCB />
      </div>
      <button
        onClick={
          handleQuery(
            name,
            targetLinkable,
            communityCourseIds(courseState),
            authenticityToken,
            setSaving,
            community,
            addCommunityCB,
            updateCommunitiesCB,
            connections,
          )
        }
        key="communities-editor__update-button"
        className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
        {
          (
            switch (community) {
            | Some(_) => "Update Community"
            | None => "Create a new community"
            }
          )
          |> str
        }
        {"Create a new community" |> str}
      </button>
    </DisablingCover>
  </div>;
};