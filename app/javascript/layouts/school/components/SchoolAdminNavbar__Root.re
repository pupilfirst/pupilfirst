[@bs.config {jsx: 3}];

exception UnknownPathEncountered(list(string));

[%bs.raw {|require("./SchoolAdminNavbar__Root.css")|}];

open SchoolAdminNavbar__Types;

type courseSelection =
  | Students
  | CourseCoaches
  | Curriculum;

type settingsSelection =
  | Customization
  | Domains
  | Homepage;

type userRole =
  | SchoolAdmin
  | CourseAuthor;

type selection =
  | Overview
  | SchoolCoaches
  | Settings(settingsSelection)
  | Courses
  | SelectedCourse(Course.id, courseSelection)
  | Communities
  | Nothing;

let str = React.string;

let containerClasses = shrunk => {
  let defaultClasses = "bg-gradient-primary-600-to-primary-800-to-bottom school-admin-navbar__primary-nav flex flex-col justify-between ";

  defaultClasses
  ++ (shrunk ? "school-admin-navbar__primary-nav--shrunk" : "overflow-y-auto");
};

let headerclasses = shrunk => {
  let defaultClasses = "school-admin-navbar__header ";
  defaultClasses
  ++ (
    shrunk ?
      "mx-auto" :
      "px-5 py-2 relative z-20 border-r border-b bg-white flex h-16 items-center"
  );
};

let imageContainerClasses = shrunk => {
  let defaultClasses = "school-admin-navbar__school-logo-container flex items-center ";
  defaultClasses
  ++ (shrunk ? "justify-center w-16 h-16" : "bg-white h-12 w-2/5 rounded");
};

let bottomLinkClasses = shrunk => {
  let defaultClasses = "flex text-white text-sm py-4 px-5 hover:bg-primary-900 font-semibold items-center ";
  defaultClasses ++ (shrunk ? "justify-center" : "");
};

let bottomLink = (path, shrunk, iconClasses, text) => {
  let title = shrunk ? Some(text) : None;

  <li>
    <a ?title href=path className={bottomLinkClasses(shrunk)}>
      <i className={iconClasses ++ " fa-fw"} />
      {shrunk ? React.null : <span className="ml-2"> {text |> str} </span>}
    </a>
  </li>;
};

let topLink = (selectedOption, currentOption, path, shrunk, iconClasses, text) => {
  let defaultClasses = "school-admin-navbar__primary-nav-link py-4 px-5";
  let classes =
    defaultClasses
    ++ (
      selectedOption == currentOption ?
        " school-admin-navbar__primary-nav-link--active" : ""
    );
  let title = shrunk ? Some(text) : None;
  <a href=path className=classes ?title>
    <i className={iconClasses ++ " fa-fw text-lg"} />
    {shrunk ? React.null : <span className="ml-2"> {text |> str} </span>}
  </a>;
};

let secondaryNavOption = (path, currentSelection, inspectedSelection, text) => {
  let defaultClasses = "flex text-indigo-800 text-sm py-3 px-4 hover:bg-gray-400 focus:bg-gray-400 font-semibold rounded items-center my-1";
  let classes =
    defaultClasses
    ++ (currentSelection == inspectedSelection ? " bg-gray-400" : "");

  <li> <a href=path className=classes> {text |> str} </a> </li>;
};

let secondaryNav = (courses, userRole, selectedOption) =>
  switch (selectedOption) {
  | Settings(settingsSelection) =>
    <div
      key="secondary-nav"
      className="bg-gray-200 school-admin-navbar__secondary-nav w-full border-r border-gray-400 pb-6 overflow-y-auto">
      <ul className="p-4">
        {
          secondaryNavOption(
            "/school/customize",
            settingsSelection,
            Customization,
            "Customization",
          )
        }
      </ul>
    </div>
  | SelectedCourse(courseId, courseSelection) =>
    <div
      key="secondary-nav"
      className="bg-gray-200 school-admin-navbar__secondary-nav w-full border-r border-gray-400 pb-6 overflow-y-auto">
      <ul className="p-4">
        <li>
          <SchoolAdminNavbar__CourseDropdown
            courses
            currentCourseId=courseId
          />
        </li>
        {
          switch (userRole) {
          | SchoolAdmin =>
            secondaryNavOption(
              "/school/courses/" ++ courseId ++ "/students",
              courseSelection,
              Students,
              "Students",
            )
          | CourseAuthor => React.null
          }
        }
        {
          switch (userRole) {
          | SchoolAdmin =>
            secondaryNavOption(
              "/school/courses/" ++ courseId ++ "/coaches",
              courseSelection,
              CourseCoaches,
              "Coaches",
            )
          | CourseAuthor => React.null
          }
        }
        {
          secondaryNavOption(
            "/school/courses/" ++ courseId ++ "/curriculum",
            courseSelection,
            Curriculum,
            "Curriculum",
          )
        }
      </ul>
    </div>
  | _ => React.null
  };

[@react.component]
let make =
    (
      ~schoolName,
      ~schoolLogoPath,
      ~schoolIconPath,
      ~courses,
      ~isStudent,
      ~isCourseAuthor,
      ~reviewPath,
    ) => {
  let url = ReasonReactRouter.useUrl();

  let userRole = isCourseAuthor ? CourseAuthor : SchoolAdmin;

  let (selectedOption, shrunk) =
    switch (url.path) {
    | ["school"] => (Overview, false)
    | ["school", "coaches"] => (SchoolCoaches, false)
    | ["school", "customize"] => (Settings(Customization), true)
    | ["school", "courses"] => (Courses, false)
    | ["school", "courses", courseId, "students"]
    | ["school", "courses", courseId, "inactive_students"] => (
        SelectedCourse(courseId, Students),
        true,
      )
    | ["school", "courses", courseId, "coaches"] => (
        SelectedCourse(courseId, CourseCoaches),
        true,
      )
    | ["school", "courses", courseId, "curriculum"] => (
        SelectedCourse(courseId, Curriculum),
        true,
      )
    | ["school", "communities"] => (Communities, false)
    | _ =>
      Rollbar.critical(
        "Unknown path encountered by SA navbar: "
        ++ (url.path |> Array.of_list |> Js.Array.joinWith("/")),
      );
      raise(UnknownPathEncountered(url.path));
    };

  [|
    <div key="main-nav" className={containerClasses(shrunk)}>
      <div>
        <div className={headerclasses(shrunk)}>
          <div className={imageContainerClasses(shrunk)}>
            {
              shrunk ?
                <a
                  href="/school"
                  className="p-2 bg-white flex items-center justify-center p-2 m-2 rounded">
                  <img src=schoolIconPath alt=schoolName />
                </a> :
                <img src=schoolLogoPath alt=schoolName />
            }
          </div>
        </div>
        /* <div
             className="flex school-admin-navbar__school-search rounded justify-end w-1/2">
             <div
               className="school-admin-navbar__school-search__icon-box flex items-center justify-center border rounded w-16">
               <i className="fas fa-search" />
             </div>
           </div> */
        {
          switch (userRole) {
          | SchoolAdmin =>
            <ul>
              <li>
                {
                  topLink(
                    selectedOption,
                    Overview,
                    "/school",
                    shrunk,
                    "fal fa-eye",
                    "Overview",
                  )
                }
              </li>
              <li>
                {
                  topLink(
                    selectedOption,
                    SchoolCoaches,
                    "/school/coaches",
                    shrunk,
                    "fal fa-chalkboard-teacher",
                    "Coaches",
                  )
                }
              </li>
              <li>
                {
                  topLink(
                    selectedOption,
                    Settings(Customization),
                    "/school/customize",
                    shrunk,
                    "fal fa-cog",
                    "Settings",
                  )
                }
              </li>
              <li>
                {
                  topLink(
                    selectedOption,
                    Courses,
                    "/school/courses",
                    shrunk,
                    "fal fa-books",
                    "Courses",
                  )
                }
                {
                  shrunk ?
                    React.null :
                    <ul className="pr-4 pb-4 ml-10 mt-1">
                      {
                        courses
                        |> List.map(course =>
                             <li key={course |> Course.id}>
                               <a
                                 href={
                                   "/school/courses/"
                                   ++ (course |> Course.id)
                                   ++ "/students"
                                 }
                                 className="block text-white py-3 px-4 hover:bg-primary-800 rounded font-semibold text-xs">
                                 {course |> Course.name |> str}
                               </a>
                             </li>
                           )
                        |> Array.of_list
                        |> React.array
                      }
                    </ul>
                }
              </li>
              <li>
                {
                  topLink(
                    selectedOption,
                    Communities,
                    "/school/communities",
                    shrunk,
                    "fal fa-users-class",
                    "Communities",
                  )
                }
              </li>
            </ul>
          | CourseAuthor => React.null
          }
        }
      </div>
      <ul>
        {
          isStudent || isCourseAuthor ?
            bottomLink("/home", shrunk, "fal fa-home-alt", "Home") :
            React.null
        }
        {
          switch (reviewPath) {
          | Some(path) =>
            bottomLink(
              path,
              shrunk,
              "fal fa-clipboard-check",
              "Review Submissions",
            )
          | None => React.null
          }
        }
        <li>
          {
            /* Using cloneElement is the only way (right now) to insert arbitrary props to an element. */
            /* Here, it is used to insert data-method="delete", which is used by Rails UJS to convert the request to a DELETE. */
            ReasonReact.cloneElement(
              <a
                title=?{shrunk ? Some("Log Out") : None}
                className={bottomLinkClasses(shrunk)}
                rel="nofollow"
                href="/users/sign_out"
              />,
              ~props={"data-method": "delete"},
              [|
                <i className="fal fa-sign-out fa-fw" />,
                shrunk ?
                  React.null :
                  <span className="ml-2"> {"Log Out" |> str} </span>,
              |],
            )
          }
        </li>
      </ul>
    </div>,
    selectedOption |> secondaryNav(courses, userRole),
  |]
  |> React.array;
};
