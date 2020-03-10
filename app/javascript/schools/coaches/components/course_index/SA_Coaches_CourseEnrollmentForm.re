open CoachesCourseIndex__Types;

let str = React.string;

type action =
  | UpdateCoachesList(array(string))
  | UpdateCoachSearchInput(string)
  | UpdateSaving;

type state = {
  courseCoaches: array(string),
  coachSearchInput: string,
  saving: bool,
};

let reducer = (state, action) =>
  switch (action) {
  | UpdateCoachesList(courseCoaches) => {...state, courseCoaches}
  | UpdateSaving => {...state, saving: !state.saving}
  | UpdateCoachSearchInput(coachSearchInput) => {...state, coachSearchInput}
  };

let setPayload = (state, authenticityToken) => {
  let payload = Js.Dict.empty();
  Js.Dict.set(
    payload,
    "authenticity_token",
    authenticityToken |> Js.Json.string,
  );
  Js.Dict.set(
    payload,
    "coach_ids",
    state.courseCoaches |> Json.Encode.(array(string)),
  );
  payload;
};

module SelectableCourseCoaches = {
  type t = Coach.t;

  let value = t => t |> Coach.name;
  let searchString = value;
};

let setCoachSearchInput = (send, value) => {
  send(UpdateCoachSearchInput(value));
};

let selectCoach = (send, state, coach) => {
  let updatedCoaches =
    state.courseCoaches |> Js.Array.concat([|coach |> Coach.id|]);
  send(UpdateCoachesList(updatedCoaches));
};

let deSelectCoach = (send, state, coach) => {
  let updatedCoaches =
    state.courseCoaches
    |> Js.Array.filter(coachId => coachId != Coach.id(coach));
  send(UpdateCoachesList(updatedCoaches));
};

module MultiselectForCourseCoaches =
  MultiselectInline.Make(SelectableCourseCoaches);

let courseCoachEditor = (schoolCoaches, state, send) => {
  let selected =
    schoolCoaches
    |> Js.Array.filter(coach =>
         state.courseCoaches |> Array.mem(Coach.id(coach))
       );
  let unselected =
    schoolCoaches
    |> Js.Array.filter(coach =>
         !(state.courseCoaches |> Array.mem(Coach.id(coach)))
       );
  <MultiselectForCourseCoaches
    placeholder="Search coaches"
    emptySelectionMessage="No coaches selected"
    allItemsSelectedMessage="You have selected all coaches!"
    selected
    unselected
    onChange={setCoachSearchInput(send)}
    value={state.coachSearchInput}
    onSelect={selectCoach(send, state)}
    onDeselect={deSelectCoach(send, state)}
  />;
};

[@react.component]
let make =
    (
      ~courseCoachIds,
      ~schoolCoaches,
      ~courseId,
      ~authenticityToken,
      ~updateCoachesCB,
    ) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {courseCoaches: courseCoachIds, coachSearchInput: "", saving: false},
    );
  let showCoachesList = schoolCoaches |> Array.length > 0;
  let handleErrorCB = () => send(UpdateSaving);
  let handleResponseCB = json => {
    let coachIds = json |> Json.Decode.(field("coach_ids", array(string)));
    Notification.success("Success", "Coach enrollments updated successfully");
    updateCoachesCB(coachIds);
  };
  let updateCourseCoaches = (courseId, state) => {
    send(UpdateSaving);
    let payload = setPayload(state, authenticityToken);
    let url = "/school/courses/" ++ courseId ++ "/update_coach_enrollments";
    Api.create(url, payload, handleResponseCB, handleErrorCB);
  };

  let saveDisabled = state.courseCoaches |> ArrayUtils.isEmpty || state.saving;

  <div className="w-full">
    <div className="w-full">
      <div className="mx-auto bg-white">
        <div className="max-w-2xl pt-6 px-6 mx-auto">
          <h5
            className="uppercase text-center border-b border-gray-400 pb-2 mb-4">
            {"ASSIGN COACHES TO THE COURSE" |> str}
          </h5>
          {showCoachesList
             ? <div>
                 <div id="course_coaches">
                   <span
                     className="inline-block mr-1 mb-2 text-xs font-semibold">
                     {"Assign or remove coaches from the course:" |> str}
                   </span>
                   {courseCoachEditor(schoolCoaches, state, send)}
                 </div>
               </div>
             : React.null}
        </div>
        <div className="flex max-w-2xl w-full mt-5 px-6 pb-5 mx-auto">
          <button
            disabled=saveDisabled
            onClick={_e => updateCourseCoaches(courseId, state)}
            className="w-full btn btn-primary btn-large">
            {"Update Course Coaches" |> str}
          </button>
        </div>
      </div>
    </div>
  </div>;
};
