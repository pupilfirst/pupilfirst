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
    <div className="flex-1 flex flex-col bg-transparent mb-3">
      <div className="inline-block relative border-b border-gray-400 rounded">
        <button
          onClick={_ => send(ToggleShowDropDown)}
          className="appearance-none flex items-center justify-between hover:bg-primary-100 hover:text-primary-500 focus:outline-none focus:bg-white focus:text-primary-500 font-semibold relative px-2 py-2 rounded w-full">
          <span>
            <i className="fas fa-book mr-2" />
            {currentCourse |> Course.name |> str}
          </span>
          <i className="far fa-chevron-down text-sm" />
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
                       className="block px-4 py-3 text-xs font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200 whitespace-no-wrap"
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