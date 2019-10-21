open CourseEditor__Types;

module CoursesQuery = [%graphql
  {|
  query {
    courses{
      id
      name
      description
      endsAt
      maxGrade
      passGrade
      enableLeaderboard
      about
      publicSignup
      gradesAndLabels {
        grade
        label
      }
    }
  }
|}
];

type props = {authenticityToken: string};

type editorAction =
  | Hidden
  | ShowForm(option(Course.t));

type state = {
  editorAction,
  courses: list(Course.t),
};

type action =
  | UpdateEditorAction(editorAction)
  | UpdateCourse(Course.t)
  | UpdateCourses(list(Course.t));

let str = ReasonReact.string;

let component = ReasonReact.reducerComponent("CourseEditor");

let make = (~authenticityToken, _children) => {
  ...component,
  initialState: () => {editorAction: Hidden, courses: []},
  reducer: (action, state) =>
    switch (action) {
    | UpdateEditorAction(editorAction) =>
      ReasonReact.Update({...state, editorAction})
    | UpdateCourses(courses) => ReasonReact.Update({...state, courses})
    | UpdateCourse(course) =>
      let newCourses = course |> Course.updateList(state.courses);
      ReasonReact.Update({...state, courses: newCourses});
    },
  didMount: ({send}) => {
    let coursesQuery = CoursesQuery.make();
    let response = coursesQuery |> GraphqlQuery.sendQuery(authenticityToken);
    response
    |> Js.Promise.then_(result => {
         let courses =
           result##courses
           |> Js.Array.map(rawCourse => {
                let endsAt =
                  switch (rawCourse##endsAt) {
                  | Some(endsAt) =>
                    Some(endsAt |> Json.Decode.string)
                    |> OptionUtils.map(DateFns.parseString)
                  | None => None
                  };
                let gradesAndLabels =
                  rawCourse##gradesAndLabels
                  |> Array.map(gradesAndLabel =>
                       GradesAndLabels.create(
                         gradesAndLabel##grade,
                         gradesAndLabel##label,
                       )
                     )
                  |> Array.to_list;

                Course.create(
                  rawCourse##id |> int_of_string,
                  rawCourse##name,
                  rawCourse##description,
                  endsAt,
                  rawCourse##maxGrade,
                  rawCourse##passGrade,
                  gradesAndLabels,
                  rawCourse##enableLeaderboard,
                  rawCourse##about,
                  rawCourse##publicSignup,
                );
              })
           |> Array.to_list;
         send(UpdateCourses(courses));
         Js.Promise.resolve();
       })
    |> ignore;
  },
  render: ({state, send}) => {
    let hideEditorActionCB = () => send(UpdateEditorAction(Hidden));
    let updateCoursesCB = course => {
      send(UpdateCourse(course));
      send(UpdateEditorAction(Hidden));
    };
    <div className="flex flex-1 h-full bg-gray-200 overflow-y-scroll">
      {switch (state.editorAction) {
       | Hidden => ReasonReact.null
       | ShowForm(course) =>
         <CourseEditor__Form
           course
           authenticityToken
           hideEditorActionCB
           updateCoursesCB
         />
       }}
      <div className="flex-1 flex flex-col">
        <div className="flex px-6 py-2 items-center justify-between">
          <button
            className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:bg-gray-100 hover:text-primary-600 hover:shadow-md focus:outline-none border-2 border-gray-400 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer"
            onClick={_ => send(UpdateEditorAction(ShowForm(None)))}>
            <i className="fas fa-plus-circle text-lg" />
            <span className="font-semibold ml-2">
              {"Add New Course" |> str}
            </span>
          </button>
        </div>
        <div className="px-6 pb-4 mt-5 flex flex-1">
          <div className="max-w-2xl w-full mx-auto relative">
            {state.courses
             |> Course.sort
             |> List.map(course =>
                  <div
                    key={course |> Course.id |> string_of_int}
                    className="flex items-center overflow-hidden shadow bg-white rounded-lg mb-4">
                    <div
                      className="flex w-full"
                      key={course |> Course.id |> string_of_int}>
                      <a
                        className="cursor-pointer flex flex-1 items-center py-6 px-4 hover:bg-gray-100"
                        onClick={_ =>
                          send(UpdateEditorAction(ShowForm(Some(course))))
                        }>
                        <div>
                          <span className="text-black font-semibold">
                            {course |> Course.name |> str}
                          </span>
                        </div>
                      </a>
                      <a
                        href={
                          "/school/courses/"
                          ++ (course |> Course.id |> string_of_int)
                          ++ "/students"
                        }
                        className="text-primary-500 bg-gray-100 hover:bg-gray-200 border-l text-sm font-semibold items-center p-4 flex cursor-pointer">
                        {"view" |> str}
                      </a>
                    </div>
                  </div>
                )
             |> Array.of_list
             |> ReasonReact.array}
          </div>
        </div>
      </div>
    </div>;
  },
};

let decode = json =>
  Json.Decode.{
    authenticityToken: json |> field("authenticityToken", string),
  };

let jsComponent =
  ReasonReact.wrapReasonForJs(
    ~component,
    jsProps => {
      let props = jsProps |> decode;
      make(~authenticityToken=props.authenticityToken, [||]);
    },
  );
