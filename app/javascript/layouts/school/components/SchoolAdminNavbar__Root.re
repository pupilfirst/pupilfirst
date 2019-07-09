[@bs.config {jsx: 3}];

[%bs.raw {|require("./SchoolAdminNavbar__Root.css")|}];

open SchoolAdminNavbar__Types;

let str = React.string;

let containerClasses = shrunk => {
  let defaultClasses = "bg-gradient-primary-600-to-primary-800-to-bottom school-admin-navbar__primary-nav flex flex-col justify-between ";

  defaultClasses
  ++ (shrunk ? "school-admin-navbar__primary-nav--shrunk" : "overflow-y-auto");
};

let secondaryNavOptionClasses = selected => {
  let defaultClasses = "flex text-indigo-800 text-sm py-3 px-4 hover:bg-gray-400 focus:bg-gray-400 font-semibold rounded items-center my-1 ";
  defaultClasses ++ (selected ? defaultClasses ++ "bg-gray-400" : "");
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
  ++ (shrunk ? "bg-white h-12 w-2/5 rounded" : "justify-center w-16 h-16");
};

[@react.component]
let make =
    (
      ~schoolName,
      ~schoolLogoPath,
      ~schoolIconPath,
      ~courses,
      ~isStudent,
      ~reviewPath,
    ) => {
  let shrunk = true;
  [|
    <div key="main-nav" className={containerClasses(shrunk)}>
      <div>
        <div className={headerclasses(shrunk)}>
          <div className="">
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
        <ul>
          <li>
            <a
              href="/school"
              className="school-admin-navbar__primary-nav-link school-admin-navbar__primary-nav-link--active py-4 px-5">
              <i className="fal fa-eye fa-fw text-lg" />
              {
                shrunk ?
                  React.null :
                  <span className="ml-2"> {"Overview" |> str} </span>
              }
            </a>
          </li>
          <li>
            <a
              href="/school/coaches"
              className="school-admin-navbar__primary-nav-link py-4 px-5">
              <i className="fal fa-chalkboard-teacher fa-fw text-lg" />
              {
                shrunk ?
                  React.null :
                  <span className="ml-2"> {"Coaches" |> str} </span>
              }
            </a>
          </li>
          <li>
            <a
              href="/school/customize"
              className="school-admin-navbar__primary-nav-link py-4 px-5">
              <i className="fal fa-cog fa-fw text-lg" />
              {
                shrunk ?
                  React.null :
                  <span className="ml-2"> {"Settings" |> str} </span>
              }
            </a>
          </li>
          <li>
            <a
              href="/school/courses"
              className="school-admin-navbar__primary-nav-link py-4 px-5">
              <i className="fal fa-books fa-fw text-lg" />
              {
                shrunk ?
                  React.null :
                  <span className="ml-2"> {"Courses" |> str} </span>
              }
            </a>
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
            <a
              href="/school/communities"
              className="school-admin-navbar__primary-nav-link py-4 px-5">
              <i className="fal fa-users-class fa-fw text-lg" />
              {
                shrunk ?
                  React.null :
                  <span className="ml-2"> {"Communities" |> str} </span>
              }
            </a>
          </li>
        </ul>
      </div>
      <ul>
        {
          isStudent ?
            <li>
              <a
                href="/home"
                className="flex text-white text-sm py-4 px-5 hover:bg-primary-900 font-semibold items-center">
                <i className="fal fa-home-alt fa-fw" />
                {
                  shrunk ?
                    React.null :
                    <span className="ml-2"> {"Home" |> str} </span>
                }
              </a>
            </li> :
            React.null
        }
        {
          switch (reviewPath) {
          | Some(path) =>
            <li>
              <a
                href=path
                className="flex text-white text-sm py-4 px-5 hover:bg-primary-900 font-semibold items-center">
                <i className="fal fa-clipboard-check fa-fw" />
                {
                  shrunk ?
                    React.null :
                    <span className="ml-2">
                      {"Review Submissions" |> str}
                    </span>
                }
              </a>
            </li>
          | None => React.null
          }
        }
        <li>
          {
            /* Using cloneElement is the only way (right now) to insert arbitrary props to an element. */
            /* Here, it is used to insert data-method="delete", which is used by Rails UJS to convert the request to a DELETE. */
            ReasonReact.cloneElement(
              <a
                className="flex text-white text-sm py-4 px-5 hover:bg-primary-900 font-semibold items-center"
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
    <div
      key="secondary-nav"
      className="bg-gray-200 school-admin-navbar__secondary-nav w-full border-r border-gray-400 pb-6 overflow-y-auto">
      <ul className="p-4">
        <li>
          <a
            href="/school/customize"
            className={secondaryNavOptionClasses(true)}>
            {"Customization" |> str}
          </a>
        </li>
        <li>
          <a
            href="#"
            className={
              secondaryNavOptionClasses(false) ++ " cursor-not-allowed"
            }
            title="WIP">
            {"Domains" |> str}
          </a>
        </li>
        <li>
          <a
            href="#"
            className={
              secondaryNavOptionClasses(false) ++ " cursor-not-allowed"
            }
            title="WIP">
            {"Homepage" |> str}
          </a>
        </li>
      </ul>
    </div>,
  |]
  |> React.array;
};
