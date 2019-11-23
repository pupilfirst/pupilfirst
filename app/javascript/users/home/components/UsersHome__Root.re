[@bs.config {jsx: 3}];

[%bs.raw {|require("courses/shared/background_patterns.css")|}];

open UsersHome__Types;

let str = React.string;

let headerSectiom = () => {
  <div> {"Header" |> str} </div>;
};

let navSection = () => {
  <div> {"nav" |> str} </div>;
};

let courseSection = courses => {
  <div className="flex w-full">
    {courses
     |> Array.map(course =>
          <div key={course |> Course.id} className="px-2 w-1/2">
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
                  <a
                    className="cursor-pointer flex flex-1 items-center py-6 px-4 hover:bg-gray-100">
                    <div>
                      <span className="text-black font-semibold">
                        {course |> Course.name |> str}
                      </span>
                    </div>
                  </a>
                  <a
                    className="text-primary-500 bg-gray-100 hover:bg-gray-200 border-l text-sm font-semibold items-center p-4 flex cursor-pointer">
                    {"Edit course" |> str}
                  </a>
                  <a
                    className="text-primary-500 bg-gray-100 hover:bg-gray-200 border-l text-sm font-semibold items-center p-4 flex cursor-pointer">
                    {"Edit Cover Image" |> str}
                  </a>
                </div>
                <div
                  className="text-gray-800 bg-gray-300 text-sm font-semibold p-4 w-full">
                  {course |> Course.description |> str}
                </div>
              </div>
            </div>
          </div>
        )
     //  {courseLinks(course)}
     |> React.array}
  </div>;
};

[@react.component]
let make = (~currentSchoolAdmin, ~courses, ~communites, ~showUserEdit) => {
  <div className="max-w-5xl mx-auto">
    {headerSectiom()}
    {navSection()}
    {courseSection(courses)}
  </div>;
};
