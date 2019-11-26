[@bs.config {jsx: 3}];

[%bs.raw {|require("courses/shared/background_patterns.css")|}];
[%bs.raw {|require("./UserHome__Root.css")|}];

open UsersHome__Types;

let str = React.string;

type view =
  | ShowCourses
  | ShowCommunities;

let headerSectiom = (userName, userTitle, avatarUrl, showUserEdit) => {
  <div
    className="max-w-4xl mx-auto pt-12 flex items-center justify-between px-3 lg:px-0">
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
           <span> {"Edit Profile" |> str} </span>
         </a>
       : React.null}
  </div>;
};

let navButtonClasses = selected => {
  "font-semibold border-b-2 border-transparent text-sm py-4 mr-6 focus:outline-none "
  ++ (selected ? "text-primary-500 border-primary-500" : "");
};

let navSection = (view, setView) => {
  <div className="border-b mt-8">
    <div className="flex max-w-4xl mx-auto px-3 lg:px-0">
      <button
        className={navButtonClasses(view == ShowCourses)}
        onClick={_ => setView(_ => ShowCourses)}>
        <i className="fas fa-book text-xs md:text-sm mr-2" />
        <span> {"My Courses" |> str} </span>
      </button>
      <button
        className={navButtonClasses(view == ShowCommunities)}
        onClick={_ => setView(_ => ShowCommunities)}>
        <i className="fas fa-users text-xs md:text-sm mr-2" />
        <span> {"Communities" |> str} </span>
      </button>
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
            | "leaderboard" => (
                "Leaderboard",
                "leaderboard",
                "fas fa-calendar-alt",
              )
            | "review" => ("Review", "review", "fas fa-check-square")
            | "students" => ("Students", "students", "fas fa-cog")
            | _unknown => ("Unknown", "", "fas fa-bug")
            };
          <a
            key=suffix
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

let ctaButton = (title, suffix, courseId) => {
  <a
    href={"/courses/" ++ courseId ++ "/" ++ suffix}
    className="flex justify-between items-center cursor-pointer">
    <span>
      <i className="text-primary-500 fas fa-book" />
      <span className="text-primary-500 font-semibold ml-2">
        {title |> str}
      </span>
    </span>
    <i className="text-primary-500 fas fa-arrow-right" />
  </a>;
};

let ctaText = message => {
  <div className="flex justify-between items-center">
    <span>
      <i className="text-primary-500 fas fa-book" />
      <span className="text-primary-500 font-semibold ml-2">
        {message |> str}
      </span>
    </span>
  </div>;
};

let callToAction = (course, currentSchoolAdmin) => {
  let courseId = course |> Course.id;

  <div className="w-full bg-gray-200 mt-4 p-4">
    {if (currentSchoolAdmin) {
       ctaButton("View Course", "curriculum", courseId);
     } else {
       switch (course |> Course.links |> Js.Array.find(l => l == "review")) {
       | Some(l) => ctaButton("Review Submissions", l, courseId)
       | None =>
         switch (
           course |> Course.exited,
           course |> Course.ended,
           course |> Course.links |> Js.Array.find(l => l == "curriculum"),
         ) {
         | (true, _, _) => ctaText("Dropped out")
         | (false, true, _) => ctaText("Course Ended")
         | (false, false, Some(l)) =>
           ctaButton("Continue Course", l, courseId)
         | (false, false, None) => React.null
         }
       };
     }}
  </div>;
};

let communityLinks = (communityIds, communities) => {
  <div className="px-4 flex flex-wrap">
    {communityIds
     |> Array.map(id => {
          let community =
            communities |> Js.Array.find(c => c |> Community.id == id);
          switch (community) {
          | Some(c) =>
            <a
              key={c |> Community.id}
              href={"/communities/" ++ (c |> Community.id)}
              className="rounded shadow mr-4 mt-4 btn">
              <i className="fas fa-users" />
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

let coursesSection = (courses, communities, currentSchoolAdmin) => {
  <div className="w-full max-w-4xl mx-auto">
    <div className="flex flex-wrap lg:-mx-5">
      {courses
       |> Array.map(course =>
            <div
              key={course |> Course.id}
              ariaLabel={course |> Course.name}
              className="w-full px-3 lg:px-5 md:w-1/2">
              <div
                key={course |> Course.id}
                className="flex items-center overflow-hidden shadow-md bg-white rounded-lg mb-4">
                <div className="w-full">
                  <div>
                    {switch (course |> Course.thumbnailUrl) {
                     | Some(url) =>
                       <img className="object-cover h-48 w-full" src=url />
                     | None =>
                       <div
                         className="h-48 svg-bg-pattern-1 user-home-course__cover"
                       />
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
                     </div>;
                   }}
                  {callToAction(course, currentSchoolAdmin)}
                </div>
              </div>
            </div>
          )
       |> React.array}
    </div>
  </div>;
};

let communitiesSection = communities => {
  <div className="mx-auto max-w-3xl">
    <div className="lg:max-w-3xl flex flex-wrap">
      {communities
       |> Array.map(community =>
            <div
              key={community |> Community.id}
              className="flex flex-col w-full md:w-1/2 px-2">
              <a
                className="h-full mt-3 border border-gray-400 rounded-lg hover:shadow hover:border-gray-500"
                href={"communities/" ++ (community |> Community.id)}>
                <div
                  className="user-home-community__cover flex w-full bg-gray-600 h-15 svg-bg-pattern-5 items-center justify-center p-4 shadow rounded-t-lg"
                />
                <div
                  className="w-full flex justify-between items-center flex-wrap px-4 pt-2 pb-4">
                  <h4 className="font-bold text-sm pt-2 leading-tight">
                    {community |> Community.name |> str}
                  </h4>
                  <div className="btn btn-small btn-primary-ghost mt-2">
                    {"Visit Community" |> str}
                  </div>
                </div>
              </a>
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
  let (view, setView) = React.useState(() => ShowCourses);
  <div className="bg-gray-100">
    <div className="bg-white">
      {headerSectiom(userName, userTitle, avatarUrl, showUserEdit)}
      {navSection(view, setView)}
    </div>
    <div className="py-8">
      {switch (view) {
       | ShowCourses =>
         coursesSection(courses, communities, currentSchoolAdmin)
       | ShowCommunities => communitiesSection(communities)
       }}
    </div>
  </div>;
};
