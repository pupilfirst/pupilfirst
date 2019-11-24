[@bs.config {jsx: 3}];

[%bs.raw {|require("courses/shared/background_patterns.css")|}];

open UsersHome__Types;

let str = React.string;

let headerSectiom = (userName, userTitle, avatarUrl, showUserEdit) => {
  <div
    className="flex max-w-3xl mx-auto justify-between pt-10 items-center px-2">
    <div className="flex">
      {switch (avatarUrl) {
       | Some(src) => <img className="w-12 h-12 rounded-full mr-4" src />
       | None => <Avatar name=userName className="w-12 h-12 mr-4" />
       }}
      <div className="text-sm flex flex-col justify-center">
        <div className="text-black font-bold inline-block">
          {userName |> str}
        </div>
        <div className="text-gray-600 inline-block"> {userTitle |> str} </div>
      </div>
    </div>
    {showUserEdit
       ? <a className="btn" href="/user/edit">
           <i className="fas fa-edit text-xs md:text-sm mr-2" />
           <span> {"Edit profile" |> str} </span>
         </a>
       : React.null}
  </div>;
};

let navSection = () => {
  <div className="border-b mt-6">
    <div className="flex max-w-3xl mx-auto">
      <div className="py-4 border-b-2 border-primary-500 mr-6">
        <i className="fas fa-edit text-xs md:text-sm mr-2" />
        <span> {"My Courses" |> str} </span>
      </div>
      <div className="py-4 mr-2">
        <i className="fas fa-edit text-xs md:text-sm mr-2" />
        <span> {"Communities" |> str} </span>
      </div>
    </div>
  </div>;
};

let courseLinks = (links, courseId) => {
  <div className="flex flex-wrap px-4">
    {links
     |> Array.map(l => {
          let (title, suffix, icon) =
            switch (l) {
            | "curriculum" => ("Curriculum", "curriculum", "fas fa-book")
            | "calendar" => ("Calendar", "calendar", "fas fa-book")
            | "leaderboard" => ("Leaderboard", "leaderboard", "fas fa-book")
            | "review" => ("Review", "review", "fas fa-book")
            | "students" => ("Students", "students", "fas fa-book")
            | _unknown => ("Unknown", "", "fas fa-book")
            };
          <a
            href={"/courses/" ++ courseId ++ "/" ++ suffix}
            className="rounded shadow mr-4 mt-4 btn">
            <i className=icon />
            <span className="text-black font-semibold ml-2">
              {title |> str}
            </span>
          </a>;
        })
     |> React.array}
  </div>;
};

let callToAction = course => {
  <div className="w-full bg-gray-300 mt-4 p-4">
    <div> {"Visit Course" |> str} </div>
  </div>;
};

let communityLinks = (communityIds, communities) => {
  <div className="px-4 flex flex-wrap mt-4">
    {communityIds
     |> Array.map(id => {
          let community =
            communities |> Js.Array.find(c => c |> Community.id == id);
          switch (community) {
          | Some(c) =>
            <a
              href={"/communities/" ++ (c |> Community.id)}
              className="rounded shadow mr-4 mt-4 btn">
              <i className="fas fa-book" />
              <span className="text-black font-semibold ml-2">
                {c |> Community.name |> str}
              </span>
            </a>
          | None => React.null
          };
        })
     |> React.array}
  </div>;
};

let courseSection = (courses, communities) => {
  <div className="bg-gray-200 py-8">
    <div className="flex flex-wrap w-full max-w-3xl mx-auto">
      {courses
       |> Array.map(course =>
            <div key={course |> Course.id} className="px-2 w-full md:w-1/2">
              <div
                key={course |> Course.id}
                className="flex items-center overflow-hidden shadow bg-white rounded-lg mb-4">
                <div className="w-full">
                  <div>
                    {switch (course |> Course.imageUrl) {
                     | Some(url) =>
                       <img className="object-cover h-48 w-full" src=url />
                     | None => <div className="h-48 svg-bg-pattern-1" />
                     }}
                  </div>
                  <div className="flex w-full" key={course |> Course.id}>
                    <div className="-mt-10 px-4">
                      <div>
                        <span className="text-white font-semibold">
                          {course |> Course.name |> str}
                        </span>
                      </div>
                    </div>
                  </div>
                  <div
                    className="text-gray-800 text-sm font-semibold p-4 w-full">
                    {course |> Course.description |> str}
                  </div>
                  {if (course |> Course.exited) {
                     <div className="text-sm p-4 bg-red-100 rounded">
                       {"Your student profile for this course is locked, and cannot be updated."
                        |> str}
                     </div>;
                   } else {
                     <div>
                       {courseLinks(
                          course |> Course.links,
                          course |> Course.id,
                        )}
                       {communityLinks(
                          course |> Course.linkedCommunities,
                          communities,
                        )}
                       {callToAction(course)}
                     </div>;
                   }}
                </div>
              </div>
            </div>
          )
       |> React.array}
    </div>
  </div>;
};

[@react.component]
let make =
    (
      ~currentSchoolAdmin,
      ~courses,
      ~communities,
      ~showUserEdit,
      ~userName,
      ~userTitle,
      ~avatarUrl,
    ) => {
  <div>
    {headerSectiom(userName, userTitle, avatarUrl, showUserEdit)}
    {navSection()}
    {courseSection(courses, communities)}
  </div>;
};
