open CoachesCourseIndex__Types;

let str = React.string;

type courseCoachlist = (int, string, bool);

type action =
  | UpdateCoachesList(int, string, bool)
  | UpdateSaving;

type state = {
  courseCoaches: list(courseCoachlist),
  saving: bool,
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateCoachesList(key, value, selected) =>
    let oldCoach =
      state.courseCoaches |> List.filter(((item, _, _)) => item !== key);
    {...state, courseCoaches: [(key, value, selected), ...oldCoach]};
  | UpdateSaving => {...state, saving: !state.saving}
  };

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

let computeInitialState = ((schoolCoaches, courseCoachIds)) => {
  courseCoaches: handleCoachAdditionList(schoolCoaches, courseCoachIds),
  saving: false,
};

[@react.component]
let make =
    (
      ~courseCoachIds,
      ~schoolCoaches,
      ~courseId,
      ~closeFormCB,
      ~authenticityToken,
      ~updateCoachesCB,
    ) => {
  let (state, send) =
    React.useReducerWithMapState(
      reducer,
      (schoolCoaches, courseCoachIds),
      computeInitialState,
    );
  let showCoachesList = schoolCoaches |> List.length > 0;
  let multiSelectCoachEnrollmentsCB = (key, value, selected) =>
    send(UpdateCoachesList(key, value, selected));
  let handleErrorCB = () => send(UpdateSaving);
  let handleResponseCB = json => {
    let coachIds = json |> Json.Decode.(field("coach_ids", list(int)));
    Notification.success("Success", "Coach enrollments updated successfully");
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
          <i className="fas fa-times text-xl" />
        </button>
      </div>
      <div className="drawer-right-form w-full">
        <div className="w-full">
          <div className="mx-auto bg-white">
            <div className="max-w-2xl pt-6 px-6 mx-auto">
              <h5
                className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
                {"ADD NEW COACHES TO THE COURSE" |> str}
              </h5>
              {showCoachesList
                 ? <div>
                     <div id="course_coaches">
                       <School__SelectBox
                         items={
                           state.courseCoaches
                           |> School__SelectBox.convertOldItems
                         }
                         selectCB={
                           multiSelectCoachEnrollmentsCB
                           |> School__SelectBox.convertOldCallback
                         }
                       />
                     </div>
                   </div>
                 : React.null}
            </div>
            <div className="flex max-w-2xl w-full mt-5 px-6 pb-5 mx-auto">
              <button
                disabled=saveDisabled
                onClick={_e => updateCourseCoaches(courseId, state)}
                className="w-full btn btn-primary btn-large">
                {"Add Course Coaches" |> str}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>;
};
