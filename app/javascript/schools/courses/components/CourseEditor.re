open CourseEditor__Types;

[%bs.raw {|require("courses/shared/background_patterns.css")|}];

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
      featured
      cover{
        url
        filename
      }
      thumbnail{
        url
        filename
      }
      gradesAndLabels {
        grade
        label
      }
    }
  }
|}
];

type editorAction =
  | Hidden
  | ShowForm(option(Course.t))
  | ShowCoverImageForm(Course.t);

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

let hideEditorAction = (send, ()) => send(UpdateEditorAction(Hidden));

let updateCourse = (send, course) => {
  send(UpdateCourse(course));
};

let courseLinks = course => {
  <div className="flex">
    <a
      href={
        "/school/courses/"
        ++ (course |> Course.id |> string_of_int)
        ++ "/curriculum"
      }
      className="text-primary-500 bg-gray-100 hover:bg-gray-200 border-l text-sm font-semibold items-center p-4 flex cursor-pointer">
      {"Curriculum" |> str}
    </a>
    <a
      href={
        "/school/courses/"
        ++ (course |> Course.id |> string_of_int)
        ++ "/students"
      }
      className="text-primary-500 bg-gray-100 hover:bg-gray-200 border-l text-sm font-semibold items-center p-4 flex cursor-pointer">
      {"Students" |> str}
    </a>
    <a
      href={
        "/school/courses/"
        ++ (course |> Course.id |> string_of_int)
        ++ "/coaches"
      }
      className="text-primary-500 bg-gray-100 hover:bg-gray-200 border-l text-sm font-semibold items-center p-4 flex cursor-pointer">
      {"Coaches" |> str}
    </a>
    <a
      href={
        "/school/courses/"
        ++ (course |> Course.id |> string_of_int)
        ++ "/exports"
      }
      className="text-primary-500 bg-gray-100 hover:bg-gray-200 border-l text-sm font-semibold items-center p-4 flex cursor-pointer">
      {"Exports" |> str}
    </a>
  </div>;
};

let make = _children => {
  ...component,
  initialState: () => {editorAction: Hidden, courses: []},
  reducer: (action, state) =>
    switch (action) {
    | UpdateEditorAction(editorAction) =>
      ReasonReact.Update({...state, editorAction})
    | UpdateCourses(courses) => ReasonReact.Update({...state, courses})
    | UpdateCourse(course) =>
      let newCourses = course |> Course.updateList(state.courses);
      ReasonReact.Update({courses: newCourses, editorAction: Hidden});
    },
  didMount: ({send}) => {
    let coursesQuery = CoursesQuery.make();
    let response =
      coursesQuery |> GraphqlQuery.sendQuery(AuthenticityToken.fromHead());
    response
    |> Js.Promise.then_(result => {
         let courses =
           result##courses
           |> Js.Array.map(rawCourse => Course.makeFromJs(rawCourse))
           |> Array.to_list;
         send(UpdateCourses(courses));
         Js.Promise.resolve();
       })
    |> ignore;
  },
  render: ({state, send}) => {
    <div className="flex flex-1 h-full bg-gray-200 overflow-y-scroll">
      {switch (state.editorAction) {
       | Hidden => ReasonReact.null
       | ShowForm(course) =>
         <CourseEditor__Form
           course
           hideEditorActionCB={hideEditorAction(send)}
           updateCourseCB={updateCourse(send)}
         />
       | ShowCoverImageForm(course) =>
         <CourseEditor__CoverImageForm
           course
           updateCourseCB={updateCourse(send)}
           closeDrawerCB={hideEditorAction(send)}
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
          <div className="max-w-3xl flex flex-wrap mx-auto">
            {state.courses
             |> Course.sort
             |> List.map(course =>
                  <div className="px-2 w-1/2">
                    <div
                      key={course |> Course.id |> string_of_int}
                      className="flex items-center overflow-hidden shadow bg-white rounded-lg mb-4">
                      <div className="w-full">
                        <div>
                          {switch (course |> Course.thumbnail) {
                           | Some(image) =>
                             <img
                               className="object-cover h-48 w-full"
                               src={image |> Course.imageUrl}
                             />
                           | None => <div className="h-48 svg-bg-pattern-1" />
                           }}
                        </div>
                        <div
                          className="flex w-full"
                          key={course |> Course.id |> string_of_int}>
                          <a
                            className="cursor-pointer flex flex-1 items-center py-6 px-4 hover:bg-gray-100"
                            onClick={_ =>
                              send(
                                UpdateEditorAction(ShowForm(Some(course))),
                              )
                            }>
                            <div>
                              <span className="text-black font-semibold">
                                {course |> Course.name |> str}
                              </span>
                            </div>
                          </a>
                          <a
                            onClick={_ =>
                              send(
                                UpdateEditorAction(ShowForm(Some(course))),
                              )
                            }
                            className="text-primary-500 bg-gray-100 hover:bg-gray-200 border-l text-sm font-semibold items-center p-4 flex cursor-pointer">
                            {"Edit course" |> str}
                          </a>
                          <a
                            onClick={_ =>
                              send(
                                UpdateEditorAction(
                                  ShowCoverImageForm(course),
                                ),
                              )
                            }
                            className="text-primary-500 bg-gray-100 hover:bg-gray-200 border-l text-sm font-semibold items-center p-4 flex cursor-pointer">
                            {"Edit Images" |> str}
                          </a>
                        </div>
                        <div
                          className="text-gray-800 bg-gray-300 text-sm font-semibold p-4 w-full">
                          <span> {course |> Course.description |> str} </span>
                          <span>
                            <a
                              href={
                                "/courses/"
                                ++ (course |> Course.id |> string_of_int)
                              }
                              className="text-sm font-semibold cursor-pointer ml-2 text-primary-500">
                              {"View course page" |> str}
                            </a>
                          </span>
                        </div>
                        {courseLinks(course)}
                      </div>
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
