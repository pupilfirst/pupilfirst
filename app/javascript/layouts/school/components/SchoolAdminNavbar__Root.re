[@bs.config {jsx: 3}];

open SchoolAdminNavbar__Types;

let str = React.string;

[@react.component]
let make = (~schoolName, ~schoolLogoPath, ~courses, ~isStudent, ~reviewPath) =>
  <div
    className="bg-gradient-primary-600-to-primary-800-to-bottom global-sidebar__primary-nav global-sidebar__primary-nav--expanded flex flex-col justify-between overflow-y-auto">
    <div>
      <div
        className="global-sidebar__header px-5 py-2 relative z-20 border-r border-b bg-white flex h-16 items-center">
        <div
          className="global-sidebar__school-logo-container flex items-center bg-white h-12 w-2/5 rounded">
          <img src=schoolLogoPath alt=schoolName />
        </div>
        <div
          className="flex global-sidebar__school-search rounded justify-end w-1/2">
          <div
            className="global-sidebar__school-search__icon-box flex items-center justify-center border rounded w-16">
            <i className="fas fa-search" />
          </div>
        </div>
      </div>
      <ul>
        <li>
          <a
            href="/school"
            className="global-sidebar__primary-nav-link global-sidebar__primary-nav-link--active py-4 px-5">
            <i className="fal fa-eye fa-fw text-lg mr-2" />
            <span> {"Overview" |> str} </span>
          </a>
        </li>
        <li>
          <a
            href="/school/coaches"
            className="global-sidebar__primary-nav-link py-4 px-5">
            <i className="fal fa-chalkboard-teacher fa-fw text-lg mr-2" />
            <span> {"Coaches" |> str} </span>
          </a>
        </li>
        <li>
          <a
            href="/school/customize"
            className="global-sidebar__primary-nav-link py-4 px-5">
            <i className="fal fa-cog fa-fw text-lg mr-2" />
            <span> {"Settings" |> str} </span>
          </a>
        </li>
        <li>
          <a
            href="/school/courses"
            className="global-sidebar__primary-nav-link py-4 px-5">
            <i className="fal fa-books fa-fw text-lg mr-2" />
            <span> {"Courses" |> str} </span>
          </a>
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
        </li>
        <li>
          <a
            href="/school/communities"
            className="global-sidebar__primary-nav-link py-4 px-5">
            <i className="fal fa-users-class fa-fw text-lg mr-2" />
            <span> {"Communities" |> str} </span>
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
              <span className="ml-2"> {"Home" |> str} </span>
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
              <span className="ml-2"> {"Review Submissions" |> str} </span>
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
              <span className="ml-2"> {"Log Out" |> str} </span>,
            |],
          )
        }
      </li>
    </ul>
  </div>;
