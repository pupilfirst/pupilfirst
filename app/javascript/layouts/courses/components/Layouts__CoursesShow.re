open Layout__courses;

type props = {
  courses: list(Course.t),
  currentCourse: Course.t,
};

type state = {showDropDown: bool};

type action =
  | ToggleShowDropDown;

let str = ReasonReact.string;

let component = ReasonReact.reducerComponent("Layouts__CoursesShow");

let make = (~courses, ~currentCourse, _children) => {
  ...component,
  initialState: () => {showDropDown: false},
  reducer: (action, state) =>
    switch (action) {
    | ToggleShowDropDown =>
      ReasonReact.Update({showDropDown: !state.showDropDown})
    },
  render: ({state, send}) =>
    <div className="flex-1 flex flex-col bg-white mb-3">
      <div className="inline-block relative">
        <button
          onClick={_ => send(ToggleShowDropDown)}
          className="appearance-none flex items-center justify-between font-medium relative px-4 py-2 rounded w-full">
          {currentCourse |> Course.name |> str}
          <i className="material-icons"> {"arrow_drop_down" |> str} </i>
        </button>
        {
          state.showDropDown ?
            <div
              className="bg-white shadow-lg rounded-b-lg border absolute overflow-hidden min-w-full w-auto z-50">
              {
                courses
                |> Course.sort
                |> List.filter(course =>
                     course |> Course.id != (currentCourse |> Course.id)
                   )
                |> List.map(course =>
                     <a
                       className="no-underline block px-4 py-3 text-xs font-semibold text-grey-darkest border-b border-grey-200 bg-white hover:text-primary-500 hover:bg-grey-200 whitespace-no-wrap"
                       key={course |> Course.id |> string_of_int}
                       href={course |> Course.path}>
                       {course |> Course.name |> str}
                     </a>
                   )
                |> Array.of_list
                |> ReasonReact.array
              }
            </div> :
            ReasonReact.null
        }
      </div>
    </div>,
};

let decode = json =>
  Json.Decode.{
    courses: json |> field("courses", list(Course.decode)),
    currentCourse: json |> field("currentCourse", Course.decode),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(~courses=props.courses, ~currentCourse=props.currentCourse, [||]);
    },
  );