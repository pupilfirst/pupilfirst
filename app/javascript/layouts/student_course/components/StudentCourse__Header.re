[@bs.config {jsx: 3}];
let str = React.string;
[%bs.raw {|require("./StudentCourse__Header.css")|}];
[%bs.raw {|require("courses/shared/background_patterns.css")|}];

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

let courseDropdown =
    (currentCourse, otherCourses, showCourses, setShowCourses) => {
  <div className="w-full relative">
    {switch (otherCourses) {
     | [] =>
       <div
         className="flex max-w-3xl mx-auto items-center relative justify-between font-semibold relative px-3 py-2 rounded w-full text-2xl text-white">
         <span className="truncate w-full text-center">
           {currentCourse |> Course.name |> str}
         </span>
       </div>
     | otherCourses =>
       <div className="student-course__dropdown max-w-xs relative mx-auto">
         <button
           key={"dropdown-course" ++ (currentCourse |> Course.id)}
           onClick={_ => setShowCourses(showCourses => !showCourses)}
           className="dropdown__btn max-w-xs mx-auto text-white appearance-none flex items-center relative justify-between focus:outline-none font-semibold w-full text-lg md:text-2xl">
           <span className="truncate w-full text-center">
             {currentCourse |> Course.name |> str}
           </span>
           <div
             className="student-course__dropdown-btn ml-3 hover:bg-primary-100 hover:text-primary-500 flex items-center justify-between px-3 py-2 rounded">
             <i className="fas fa-chevron-down text-xs font-semibold" />
           </div>
         </button>
         {showCourses
            ? <ul
                key="dropdown-course-list"
                className="dropdown__list bg-white shadow-lg rounded mt-1 border absolute overflow-hidden min-w-full w-auto z-20">
                {courseOptions(otherCourses)}
              </ul>
            : React.null}
       </div>
     }}
  </div>;
};

let courseDropdownClasses = additionalLinks => {
  "absolute px-4 lg:px-0 "
  ++ (
    additionalLinks |> ListUtils.isEmpty
      ? "student-course__dropdown-container--without-sub-nav"
      : "student-course__dropdown-container--with-sub-nav"
  );
};

let renderCourseSelector =
    (
      currentCourseId,
      courses,
      showCourses,
      setShowCourses,
      coverImage,
      additionalLinks,
    ) => {
  let currentCourse =
    courses
    |> ListUtils.unsafeFind(
         c => c |> Course.id == currentCourseId,
         "Could not find current course with ID "
         ++ currentCourseId
         ++ " in StudentCourse__Header",
       );
  let otherCourses =
    courses |> List.filter(c => c |> Course.id != currentCourseId);
  <div className="relative bg-primary-900">
    <div className="relative pb-1/2 md:pb-1/4 2xl:pb-1/6">
      {switch (coverImage) {
       | Some(src) =>
         <img className="absolute h-full w-full object-cover" src />
       | None =>
         <div
           className="student-course__cover-default absolute h-full w-full svg-bg-pattern-1"
         />
       }}
    </div>
    <div className="max-w-3xl mx-auto relative">
      <div className={courseDropdownClasses(additionalLinks)}>
        {courseDropdown(
           currentCourse,
           otherCourses,
           showCourses,
           setShowCourses,
         )}
      </div>
    </div>
  </div>;
};

let tabClasses = (url: ReasonReactRouter.url, linkTitle) => {
  let defaultClasses = "student-course__nav-tab py-4 px-2 text-center flex-1 font-semibold text-sm ";
  switch (url.path) {
  | ["courses", _targetId, pageTitle, ..._] when pageTitle == linkTitle =>
    defaultClasses ++ "student-course__nav-tab--active"
  | _ => defaultClasses
  };
};

[@react.component]
let make = (~currentCourseId, ~courses, ~additionalLinks, ~coverImage) => {
  let (showCourses, setShowCourses) = React.useState(() => false);
  let url = ReasonReactRouter.useUrl();

  <div>
    {renderCourseSelector(
       currentCourseId,
       courses,
       showCourses,
       setShowCourses,
       coverImage,
       additionalLinks,
     )}
    {switch (additionalLinks) {
     | [] => React.null
     | additionalLinks =>
       <div className="md:px-3">
         <div
           className="bg-white border-transparent flex justify-between overflow-x-auto md:overflow-hidden lg:max-w-3xl mx-auto shadow md:rounded-lg -mt-7 z-10 relative">
           {additionalLinks
            |> List.append(["curriculum"])
            |> List.map(l => {
                 let (title, suffix) =
                   switch (l) {
                   | "curriculum" => ("Curriculum", "curriculum")
                   | "calendar" => ("Calendar", "calendar")
                   | "leaderboard" => ("Leaderboard", "leaderboard")
                   | "review" => ("Review", "review")
                   | "students" => ("Students", "students")
                   | _unknown => ("Unknown", "")
                   };

                 <a
                   key=title
                   href={"/courses/" ++ currentCourseId ++ "/" ++ suffix}
                   className={tabClasses(url, suffix)}>
                   {title |> str}
                 </a>;
               })
            |> Array.of_list
            |> React.array}
         </div>
       </div>
     }}
  </div>;
};
