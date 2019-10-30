open CoachesCourseIndex__Types;

let str = ReasonReact.string;

type formVisible =
  | None
  | CoachEnrollmentForm;

type state = {
  courseCoaches: list(Coach.t),
  teamCoaches: list(Coach.t),
  formVisible,
  saving: bool,
};

type action =
  | UpdateFormVisible(formVisible)
  | UpdateCoaches(list(int))
  | RemoveCoach(int)
  | UpdateSaving;

let component = ReasonReact.reducerComponent("SA_Coaches_CourseIndex");

let handleErrorCB = (send, ()) => {
  send(UpdateSaving);
  Notification.error(
    "Coach enrollment could not be deleted",
    "Please try again",
  );
};

let handleResponseCB = (send, json) => {
  send(UpdateSaving);
  let coachId = json |> Json.Decode.(field("coach_id", int));
  send(RemoveCoach(coachId));
  Notification.success("Success", "Coach enrollment deleted successfully");
};

let removeCoach = (send, courseId, authenticityToken, coach, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  if (Webapi.Dom.(
        window
        |> Window.confirm(
             "Are you sure you want to remove "
             ++ (coach |> Coach.name)
             ++ " from this course?",
           )
      )) {
    send(UpdateSaving);
    let url =
      "/school/courses/"
      ++ (courseId |> string_of_int)
      ++ "/delete_coach_enrollment";
    let payload = Js.Dict.empty();
    Js.Dict.set(
      payload,
      "authenticity_token",
      authenticityToken |> Js.Json.string,
    );
    Js.Dict.set(
      payload,
      "coach_id",
      coach |> Coach.id |> string_of_int |> Js.Json.string,
    );
    Api.create(url, payload, handleResponseCB(send), handleErrorCB(send));
  } else {
    ();
  };
};

let make =
    (
      ~courseCoachIds,
      ~startupCoachIds,
      ~schoolCoaches,
      ~courseId,
      ~authenticityToken,
      _children,
    ) => {
  ...component,
  initialState: () => {
    courseCoaches:
      schoolCoaches
      |> List.filter(schoolCoach =>
           courseCoachIds
           |> List.exists(facultyId => facultyId == Coach.id(schoolCoach))
         ),
    teamCoaches:
      schoolCoaches
      |> List.filter(schoolCoach =>
           startupCoachIds
           |> List.exists(facultyId => facultyId == Coach.id(schoolCoach))
         ),
    formVisible: None,
    saving: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateFormVisible(formVisible) =>
      ReasonReact.Update({...state, formVisible})
    | UpdateCoaches(coachIds) =>
      let newCoachesList =
        schoolCoaches
        |> List.filter(schoolCoach =>
             coachIds
             |> List.exists(coachId => coachId == Coach.id(schoolCoach))
           );
      let newTeamCoaches =
        state.teamCoaches
        |> List.filter(teamCoach =>
             !(
               newCoachesList |> List.exists(newCoach => newCoach == teamCoach)
             )
           );
      ReasonReact.Update({
        ...state,
        courseCoaches: newCoachesList,
        teamCoaches: newTeamCoaches,
      });
    | RemoveCoach(coachId) =>
      ReasonReact.Update({
        ...state,
        courseCoaches:
          state.courseCoaches
          |> List.filter(courseCoach => Coach.id(courseCoach) !== coachId),
        teamCoaches:
          state.teamCoaches
          |> List.filter(teamCoach => Coach.id(teamCoach) !== coachId),
      })
    | UpdateSaving => ReasonReact.Update({...state, saving: !state.saving})
    },
  render: ({state, send}) => {
    let closeFormCB = () => send(UpdateFormVisible(None));
    let updateCoachesCB = coachIds => {
      send(UpdateCoaches(coachIds));
      send(UpdateFormVisible(None));
    };

    <DisablingCover.Jsx2 containerClasses="w-full" disabled={state.saving}>
      <div
        key="School admin coaches course index"
        className="flex flex-1 h-full overflow-y-scroll bg-gray-100">
        {switch (state.formVisible) {
         | None => ReasonReact.null
         | CoachEnrollmentForm =>
           let courseCoachIds =
             state.courseCoaches |> List.map(coach => coach |> Coach.id);
           <SA_Coaches_CourseEnrollmentForm
             courseId
             courseCoachIds
             schoolCoaches
             updateCoachesCB
             closeFormCB
             authenticityToken
           />;
         }}
        <div className="flex-1 flex flex-col">
          {List.length(schoolCoaches) == List.length(state.courseCoaches)
           || ListUtils.isEmpty(schoolCoaches)
             ? ReasonReact.null
             : <div className="flex px-6 py-2 items-center justify-between">
                 <button
                   onClick={_event => {
                     ReactEvent.Mouse.preventDefault(_event);
                     send(UpdateFormVisible(CoachEnrollmentForm));
                   }}
                   className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hove:bg-gray-100 hover:text-primary-600 hover:shadow-lg focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer">
                   <i className="fas fa-user-plus text-lg" />
                   <h5 className="font-semibold ml-2">
                     {"Assign Coaches to Course" |> str}
                   </h5>
                 </button>
               </div>}
          {state.teamCoaches
           |> ListUtils.isEmpty
           && state.courseCoaches
           |> ListUtils.isEmpty
             ? <div
                 className="flex justify-center bg-gray-100 border rounded p-3 italic mx-auto max-w-2xl w-full">
                 {"The course has no coaches assigned!" |> str}
               </div>
             : ReasonReact.null}
          <div className="px-6 pb-4 mt-5 flex flex-1">
            <div className="max-w-2xl w-full mx-auto relative">
              {state.courseCoaches |> ListUtils.isEmpty
                 ? ReasonReact.null
                 : <h4 className="w-full"> {"Course Coaches:" |> str} </h4>}
              <div
                className="flex mt-4 -mx-3 flex-wrap"
                ariaLabel="List of course coaches">
                {state.courseCoaches
                 |> List.sort((x, y) => (x |> Coach.id) - (y |> Coach.id))
                 |> List.map(coach =>
                      <div
                        key={coach |> Coach.id |> string_of_int}
                        className="flex w-1/2 flex-shrink-0 mb-5 px-3">
                        <div
                          id={coach |> Coach.name}
                          className="course-faculty__list-item shadow bg-white rounded-lg flex w-full">
                          <div className="flex flex-1 justify-between">
                            <div className="flex py-4 px-4">
                              <img
                                className="w-10 h-10 rounded-full mr-4 object-cover"
                                src={coach |> Coach.imageUrl}
                                alt={"Avatar of " ++ (coach |> Coach.name)}
                              />
                              <div className="text-sm">
                                <p className="text-black font-semibold mt-1">
                                  {coach |> Coach.name |> str}
                                </p>
                                <p
                                  className="text-gray-600 font-semibold text-xs mt-px">
                                  {coach |> Coach.title |> str}
                                </p>
                              </div>
                            </div>
                            <div
                              className="w-10 text-sm course-faculty__list-item-remove text-gray-700 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-200"
                              ariaLabel={"Delete " ++ (coach |> Coach.name)}
                              onClick={removeCoach(
                                send,
                                courseId,
                                authenticityToken,
                                coach,
                              )}>
                              <i className="fas fa-trash-alt" />
                            </div>
                          </div>
                        </div>
                      </div>
                    )
                 |> Array.of_list
                 |> ReasonReact.array}
              </div>
              {state.teamCoaches |> ListUtils.isEmpty
                 ? ReasonReact.null
                 : <h4 className="mt-5 w-full">
                     {"Student/Team Coaches:" |> str}
                   </h4>}
              <div className="flex mt-4 -mx-3 items-start flex-wrap">
                {state.teamCoaches
                 |> List.sort((x, y) => (x |> Coach.id) - (y |> Coach.id))
                 |> List.map(coach =>
                      <div
                        key={coach |> Coach.id |> string_of_int}
                        className="flex w-1/2 items-center mb-4 px-3">
                        <div
                          className="course-faculty__list-item shadow bg-white overflow-hidden rounded-lg flex flex-col w-full">
                          <div className="flex flex-1 justify-between">
                            <div className="flex pt-4 pb-3 px-4">
                              <img
                                className="w-10 h-10 rounded-full mr-4 object-cover"
                                src={coach |> Coach.imageUrl}
                                alt={"Avatar of " ++ Coach.name(coach)}
                              />
                              <div className="text-sm">
                                <p className="text-black font-semibold">
                                  {coach |> Coach.name |> str}
                                </p>
                                <p
                                  className="text-gray-600 font-semibold text-xs mt-px">
                                  {coach |> Coach.title |> str}
                                </p>
                              </div>
                            </div>
                            <div
                              ariaLabel={"Delete " ++ (coach |> Coach.name)}
                              className="w-10 text-xs text-sm course-faculty__list-item-remove text-gray-700 hover:text-gray-900 cursor-pointer flex items-center justify-center hover:bg-gray-200"
                              onClick={removeCoach(
                                send,
                                courseId,
                                authenticityToken,
                                coach,
                              )}>
                              <i className="fas fa-trash-alt" />
                            </div>
                          </div>
                          <div className="pt-2 pb-4 px-4">
                            <h6
                              className="font-semibold text-gray-600 border-b pb-1">
                              {"Teams" |> str}
                            </h6>
                            {switch (coach |> Coach.teams) {
                             | None => ReasonReact.null
                             | Some(teams) =>
                               <div
                                 className="flex flex-wrap text-gray-600 font-semibold text-xs mt-1">
                                 {teams
                                  |> List.map(team =>
                                       <span
                                         key={"Team " ++ Team.name(team)}
                                         className="px-2 py-1 border rounded bg-primary-100 text-primary-600 mt-1 mr-1">
                                         {Team.name(team) |> str}
                                       </span>
                                     )
                                  |> Array.of_list
                                  |> ReasonReact.array}
                               </div>
                             }}
                          </div>
                        </div>
                      </div>
                    )
                 |> Array.of_list
                 |> ReasonReact.array}
              </div>
            </div>
          </div>
        </div>
      </div>
    </DisablingCover.Jsx2>;
  },
};

type props = {
  courseCoachIds: list(int),
  startupCoachIds: list(int),
  schoolCoaches: list(Coach.t),
  authenticityToken: string,
  courseId: int,
};

let decode = json =>
  Json.Decode.{
    courseCoachIds: json |> field("courseCoachIds", list(int)),
    startupCoachIds: json |> field("startupCoachIds", list(int)),
    schoolCoaches: json |> field("schoolCoaches", list(Coach.decode)),
    courseId: json |> field("courseId", int),
    authenticityToken: json |> field("authenticityToken", string),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~courseCoachIds=props.courseCoachIds,
        ~startupCoachIds=props.startupCoachIds,
        ~schoolCoaches=props.schoolCoaches,
        ~courseId=props.courseId,
        ~authenticityToken=props.authenticityToken,
        [||],
      );
    },
  );
