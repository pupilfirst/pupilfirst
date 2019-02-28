open CoachesPanel__Types;

open SchoolAdmin__Utils;

let str = ReasonReact.string;

type formVisible =
  | None
  | CreateForm
  | UpdateForm(Coach.t);

type state = {
  coaches: list(Coach.t),
  selectedCoach: list(Coach.t),
  searchString: string,
  formVisible,
};

type action =
  | UpdateCoach(Coach.t)
  | SelectCoach(Coach.t)
  | DeselectCoach(Coach.t)
  | UpdateSearchString(string)
  | UpdateFormVisible(formVisible);

let component = ReasonReact.reducerComponent("SA_CoachesPanel");

let make = (~coaches, ~courseId, ~authenticityToken, _children) => {
  ...component,
  initialState: () => {
    coaches,
    selectedCoach: [],
    searchString: "",
    formVisible: None,
  },
  reducer: (action, state) =>
    switch (action) {
    | UpdateCoach(coach) => ReasonReact.Update({...state, coaches})
    },
  render: ({state, send}) =>
    <div className="flex-1 flex flex-col bg-white overflow-hidden">
      <div className="px-6 pb-4 flex-1 bg-grey-lightest overflow-y-scroll">
        <div className="max-w-lg mx-auto relative" />
      </div>
    </div>,
};

type props = {
  coaches: list(Coach.t),
  courseId: int,
  authenticityToken: string,
};

let decode = json =>
  Json.Decode.{
    coaches: json |> field("coaches", list(Coach.decode)),
    courseId: json |> field("courseId", int),
    authenticityToken: json |> field("authenticityToken", string),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~coaches=props.coaches,
        ~courseId=props.courseId,
        ~authenticityToken=props.authenticityToken,
        [||],
      );
    },
  );