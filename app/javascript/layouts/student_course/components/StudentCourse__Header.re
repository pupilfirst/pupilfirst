[@bs.config {jsx: 3}];
let str = React.string;

module Course = StudentCourse__Course;

let courseOptions = courses =>
  courses
  |> List.map(course =>
       <li
         key={course |> Course.id}
         className="cursor-pointer block p-3 text-xs font-semibold text-gray-900 border-b border-gray-200 bg-white hover:text-primary-500 hover:bg-gray-200 whitespace-no-wrap">
         <a href={"/courses/" ++ (course |> Course.id)}>
           {course |> Course.name |> str}
         </a>
       </li>
     )
  |> Array.of_list
  |> React.array;

[@react.component]
let make = (~currentCourseId, ~courses, ~additionalLinks) => {
  let currentCourse =
    courses |> List.find(c => c |> Course.id == currentCourseId);
  let otherCourses =
    courses |> List.filter(c => c |> Course.id != currentCourseId);

  <div>
    <div className="bg-gray-100 py-12">
      <div className="flex">
        <div className="dropdown relative mx-auto">
          {
            switch (otherCourses) {
            | [] =>
              <div
                className="flex bg-gray-200 items-center relative justify-between font-semibold text-sm relative px-3 py-2 rounded w-full text-2xl">
                <span> {currentCourse |> Course.name |> str} </span>
              </div>
            | otherCourses =>
              [|
                <button
                  className="dropdown__btn appearance-none flex bg-gray-200 hover:bg-primary-100 hover:text-primary-500 items-center relative justify-between focus:outline-none font-semibold text-sm relative px-3 py-2 rounded w-full text-2xl">
                  <span> {currentCourse |> Course.name |> str} </span>
                  <i
                    className="far fa-chevron-down text-xs ml-3 font-semibold"
                  />
                </button>,
                <ul
                  className="dropdown__list bg-white shadow-lg rounded mt-1 border absolute overflow-hidden min-w-full w-auto z-50">
                  {courseOptions(otherCourses)}
                </ul>,
              |]
              |> React.array
            }
          }
        </div>
      </div>
    </div>
    {
      switch (additionalLinks) {
      | [] => React.null
      | additionalLinks =>
        <div className="flex justify-center">
          <div className="bg-white border-transparent rounded-lg flex">
            <a
              href={"/courses/" ++ currentCourseId}
              className="p-4 hover:bg-grey-200">
              {"Curriculum" |> str}
            </a>
            {
              additionalLinks
              |> List.map(l => {
                   let (title, suffix) =
                     switch (l) {
                     | "calendar" => ("Calendar", "calendar")
                     | "leaderboard" => ("Leaderboard", "leaderboard")
                     | "review" => ("Review", "coach_dashboard")
                     | _unknown => ("Unknown", "")
                     };

                   <a
                     key=suffix
                     href={"/courses/" ++ currentCourseId ++ "/" ++ suffix}
                     className="p-4 hover:bg-grey-200">
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