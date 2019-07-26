open CoachesCourseIndex__Types;

type courseCoachlist = (int, string, bool);

type action =
  | UpdateCoachesList(int, string, bool)
  | UpdateSaving;

type state = {
  courseCoaches: list(courseCoachlist),
  saving: bool,
};

let component =
  ReasonReact.reducerComponent("SA_CoachesPanel_CoachEnrollmentForm");

let str = ReasonReact.string;

let handleCoachAdditionList = (schoolCoaches, courseCoachIds) => {
  let addableCoaches =
    schoolCoaches
    |> List.filter(schoolCoach =>
         !(
           courseCoachIds
           |> List.exists(courseCoachId =>
                courseCoachId == Coach.id(schoolCoach)
              )
         )
       );
  addableCoaches
  |> List.map(coach => (coach |> Coach.id, coach |> Coach.name, false));
};

let setPayload = (state, authenticityToken) => {
  let payload = Js.Dict.empty();
  let enrolledCoachIds =
    state.courseCoaches
    |> List.filter(((_, _, selected)) => selected == true)
    |> List.map(((key, _, _)) => key);
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(
    payload,
    "coach_ids",
    enrolledCoachIds |> Json.Encode.(list(int)),
  );
  payload;
};

let make =
    (
      ~courseCoachIds,
      ~schoolCoaches,
      ~courseId,
      ~closeFormCB,
      ~authenticityToken,
      ~updateCoachesCB,
      _children,
    ) => {
  ...component,
  initialState: () => {
    courseCoaches: handleCoachAdditionList(schoolCoaches, courseCoachIds),
    saving: false,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateCoachesList(key, value, selected) =>
      let oldCoach =
        state.courseCoaches |> List.filter(((item, _, _)) => item !== key);
      ReasonReact.Update({
        ...state,
        courseCoaches: [(key, value, selected), ...oldCoach],
      });
    | UpdateSaving => ReasonReact.Update({...state, saving: !state.saving})
    },
  render: ({state, send}) => {
    let showCoachesList = schoolCoaches |> List.length > 0;
    let multiSelectCoachEnrollmentsCB = (key, value, selected) =>
      send(UpdateCoachesList(key, value, selected));
    let handleErrorCB = () => send(UpdateSaving);
    let handleResponseCB = json => {
      let coachIds = json |> Json.Decode.(field("coach_ids", list(int)));
      Notification.success(
        "Success",
        "Coach enrollments updated successfully",
      );
      updateCoachesCB(coachIds);
    };
    let updateCourseCoaches = (courseId, state) => {
      send(UpdateSaving);
      let payload = setPayload(state, authenticityToken);
      let url =
        "/school/courses/"
        ++ (courseId |> string_of_int)
        ++ "/update_coach_enrollments";
      Api.create(url, payload, handleResponseCB, handleErrorCB);
    };

    let saveDisabled =
      state.courseCoaches
      |> List.filter(((_, _, selected)) => selected)
      |> ListUtils.isEmpty
      || state.saving;

    <div className="blanket">
      <div className="drawer-right">
        <div className="drawer-right__close absolute">
          <button
            title="close"
            onClick={_e => closeFormCB()}
            className="flex items-center justify-center bg-white text-gray-600 py-3 px-5 rounded-l-full rounded-r-none hover:text-gray-700 focus:outline-none mt-4">
            <i className="fal fa-times text-xl" />
          </button>
        </div>
        <div className="drawer-right-form w-full">
          <div className="w-full">
            <div className="mx-auto bg-white">
              <div className="max-w-2xl p-6 mx-auto">
                <h5
                  className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
                  {"ADD NEW COACHES TO THE COURSE" |> str}
                </h5>
                {
                  showCoachesList ?
                    <div>
                      <div id="course_coaches" className="mb-6">
                        <School__SelectBox.Jsx2
                          items={state.courseCoaches}
                          multiSelectCB=multiSelectCoachEnrollmentsCB
                        />
                      </div>
                    </div> :
                    ReasonReact.null
                }
              </div>
              <div className="flex max-w-2xl w-full px-6 pb-5 mx-auto">
                <button
                  disabled=saveDisabled
                  onClick={_e => updateCourseCoaches(courseId, state)}
                  className="w-full bg-indigo-600 hover:bg-blue-600 text-white font-bold py-3 px-6 shadow rounded focus:outline-none">
                  {"Add Course Coaches" |> str}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>;
  },
};
