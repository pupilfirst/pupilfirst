open CourseEditor__Types;

type props = {
  courses: list(Course.t),
  authenticityToken: string,
};

type editorAction =
  | Hidden
  | ShowForm(option(Course.t));

type state = {editorAction};

type action =
  | UpdateEditorAction(editorAction);

let str = ReasonReact.string;

let component = ReasonReact.reducerComponent("CourseEditor");

let make = (~courses, ~authenticityToken, _children) => {
  ...component,
  initialState: () => {editorAction: Hidden},
  reducer: (action, state) =>
    switch (action) {
    | UpdateEditorAction(editorAction) =>
      ReasonReact.Update({...state, editorAction})
    },
  render: ({state, send}) => {
    let hideEditorActionCB = () => send(UpdateEditorAction(Hidden));
    let updateCoursesCB = courses => ();
    <div className="flex flex-1 h-screen">
      {
        switch (state.editorAction) {
        | Hidden => ReasonReact.null
        | ShowForm(course) =>
          <CourseEditor__Form
            course
            authenticityToken
            hideEditorActionCB
            updateCoursesCB
          />
        }
      }
      <div className="flex-1 flex flex-col bg-grey-lightest overflow-hidden">
        <div
          className="flex px-6 py-2 items-center justify-between overflow-y-scroll">
          <button
            className="max-w-md w-full flex mx-auto items-center justify-center relative bg-grey-lighter hover:bg-grey-light hover:shadow-md border-2 border-dashed p-6 rounded-lg mt-20 cursor-pointer"
            onClick={_ => send(UpdateEditorAction(ShowForm(None)))}>
            <i className="material-icons"> {"add_circle_outline" |> str} </i>
            <h4 className="font-semibold ml-2"> {"Add New Course" |> str} </h4>
          </button>
        </div>
        <div
          className="px-6 pb-4 mt-5 flex flex-1 bg-grey-lightest overflow-y-scroll">
          <div className="max-w-md w-full mx-auto relative">
            {
              courses
              |> Course.sort
              |> List.map(course =>
                   <div
                     className="shadow bg-white rounded-lg overflow-hidden mb-4 flex items-center hover:bg-grey-lighter py-4 px-4"
                     onClick={
                       _ =>
                         send(UpdateEditorAction(ShowForm(Some(course))))
                     }>
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
    </div>;
  },
};

let decode = json =>
  Json.Decode.{
    courses: json |> field("courses", list(Course.decode)),
    authenticityToken: json |> field("authenticityToken", string),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(
        ~courses=props.courses,
        ~authenticityToken=props.authenticityToken,
        [||],
      );
    },
  );