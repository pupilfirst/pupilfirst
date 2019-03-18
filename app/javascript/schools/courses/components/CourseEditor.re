open CourseEditor__Types;

type props = {courses: list(Course.t)};

type state = {showDropDown: bool};

type action =
  | ToggleShowDropDown;

let str = ReasonReact.string;

let component = ReasonReact.reducerComponent("CourseEditor");

let make = (~courses, _children) => {
  ...component,
  initialState: () => {showDropDown: false},
  reducer: (action, state) =>
    switch (action) {
    | ToggleShowDropDown =>
      ReasonReact.Update({showDropDown: !state.showDropDown})
    },
  render: ({state, send}) =>
    <div className="flex flex-1 h-screen">
      <div className="flex-1 flex flex-col bg-grey-lightest overflow-hidden">
        <div
          className="flex px-6 py-2 items-center justify-between overflow-y-scroll">
          <div
            className="max-w-md w-full flex mx-auto items-center justify-center relative bg-grey-lighter hover:bg-grey-light hover:shadow-md border-2 border-dashed p-6 rounded-lg mt-20 cursor-pointer">
            <i className="material-icons"> {"add_circle_outline" |> str} </i>
            <h4 className="font-semibold ml-2"> {"Add New Course" |> str} </h4>
          </div>
        </div>
        <div
          className="px-6 pb-4 mt-5 flex flex-1 bg-grey-lightest overflow-y-scroll">
          <div className="max-w-md w-full mx-auto relative">
            {
              courses
              |> Course.sort
              |> List.map(course =>
                   <div
                     className="shadow bg-white rounded-lg overflow-hidden mb-4 flex items-center hover:bg-grey-lighter py-4 px-4">
                     <div className="text-sm">
                       <p className="text-black font-semibold">
                         {course |> Course.name |> str}
                       </p>
                     </div>
                   </div>
                 )
              |> Array.of_list
              |> ReasonReact.array
            }
          </div>
        </div>
      </div>
    </div>,
};

let decode = json =>
  Json.Decode.{courses: json |> field("courses", list(Course.decode))};

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(~courses=props.courses, [||]);
    },
  );