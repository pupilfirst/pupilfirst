[@bs.config {jsx: 3}];
let str = React.string;
[%bs.raw {|require("./StudentCourse__Header.css")|}];

module Course = StudentCourse__Course;

let courseOptions = courses =>
  courses
  |> List.map(course => {
       let courseId = course |> Course.id;
       <a
         key={"course-" ++ courseId}
         href={"/courses/" ++ courseId ++ "/curriculum"}
         className="cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200 whitespace-no-wrap">
         <span> {course |> Course.name |> str} </span>
       </a>;
     })
  |> Array.of_list
  |> React.array;

let renderCourseSelector =
    (currentCourseId, courses, showCourses, setShowCourses) => {
  let currentCourse =
    courses |> List.find(c => c |> Course.id == currentCourseId);
  let otherCourses =
    courses |> List.filter(c => c |> Course.id != currentCourseId);
  <div className="student-course__cover svg-bg-pattern-2 pb-22 pt-15 px-3">
    <div className="flex">
      <div className="w-full relative">
        {
          switch (otherCourses) {
          | [] =>
            <div
              className="flex max-w-3xl mx-auto items-center relative justify-between font-semibold relative px-3 py-2 rounded w-full text-2xl text-white">
              <span className="truncate w-full text-center">
                {currentCourse |> Course.name |> str}
              </span>
            </div>
          | otherCourses =>
            <div
              className="student-course__dropdown max-w-xs relative mx-auto">
              <button
                key={"dropdown-course" ++ (currentCourse |> Course.id)}
                onClick=(_ => setShowCourses(showCourses => !showCourses))
                className="dropdown__btn max-w-xs mx-auto student-course__dropdown-btn text-white appearance-none flex hover:bg-primary-100 hover:text-primary-500 items-center relative justify-between focus:outline-none font-semibold text-sm relative px-3 py-2 rounded w-full text-2xl">
                <span className="truncate w-full text-center">
                  {currentCourse |> Course.name |> str}
                </span>
                <i
                  className="far fa-chevron-down text-xs ml-3 font-semibold"
                />
              </button>
              {
                showCourses ?
                  <ul
                    key="dropdown-course-list"
                    className="dropdown__list bg-white shadow-lg rounded mt-1 border absolute overflow-hidden min-w-full w-auto z-20">
                    {courseOptions(otherCourses)}
                  </ul> :
                  React.null
              }
            </div>
          }
        }
      </div>
    </div>
  </div>;
};

[@react.component]
let make = (~currentCourseId, ~courses, ~additionalLinks) => {
  let (showCourses, setShowCourses) = React.useState(() => false);
  let url = ReasonReactRouter.useUrl();
  let tabClasses = linkTitle => {
    let defaultClasses = "student-course__nav-tab py-4 px-2 text-center flex-1 font-semibold text-sm ";
    switch (url.path) {
    | ["courses", _targetId, pageTitle, ..._] when pageTitle == linkTitle =>
      defaultClasses ++ "student-course__nav-tab--active"
    | _ => defaultClasses
    };
  };

  <div>
    {
      renderCourseSelector(
        currentCourseId,
        courses,
        showCourses,
        setShowCourses,
      )
    }
    {
      switch (additionalLinks) {
      | [] => React.null
      | additionalLinks =>
        <div className="md:px-3">
          <div
            className="bg-white border-transparent flex justify-between overflow-x-auto md:overflow-hidden lg:max-w-3xl mx-auto shadow md:rounded-lg -mt-7 z-10 relative">
            {
              additionalLinks
              |> List.append(["curriculum"])
              |> List.map(l => {
                   let (title, suffix) =
                     switch (l) {
                     | "curriculum" => ("Curriculum", "curriculum")
                     | "calendar" => ("Calendar", "calendar")
                     | "leaderboard" => ("Leaderboard", "leaderboard")
                     | "review" => ("Review", "coach_dashboard")
                     | _unknown => ("Unknown", "")
                     };

                   <a
                     key=title
                     href={"/courses/" ++ currentCourseId ++ "/" ++ suffix}
                     className={tabClasses(suffix)}>
                     {title |> str}
                   </a>;
                 })
              |> Array.of_list
              |> React.array
            }
          </div>
        </div>
      }
    }
  </div>;
};
