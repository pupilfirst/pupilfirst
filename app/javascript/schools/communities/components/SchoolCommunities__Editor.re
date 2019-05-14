[@bs.config {jsx: 3}];

let str = React.string;

open SchoolCommunities__IndexTypes;

[@react.component]
let make = (~authenticityToken, ~courses) => {
  let (saving, setSaving) = React.useState(() => false);
  let (courseState, setCourseState) =
    React.useState(() =>
      courses
      |> List.map(course =>
           (
             course |> Course.id |> int_of_string,
             course |> Course.name,
             false,
           )
         )
    );

  let multiSelectCB = (id, name, selected) => {
    let oldCourses =
      courseState |> List.filter(((courseId, _, _)) => courseId !== id);
    setCourseState(_ => [(id, name, selected), ...oldCourses]);
  };

  <div className="mx-8 pt-8">
    <h5 className="uppercase text-center border-b border-grey-light pb-2">
      {"Community Editor" |> str}
    </h5>
    <DisablingCover disabled=saving>
      <div key="communities-editor" className="mt-3">
        <label
          className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
          htmlFor="communities-editor__name">
          {"Name" |> str}
        </label>
        <input
          id="communities-editor__name"
          className="appearance-none h-10 mt-1 block w-full text-grey-darker border border-grey-light rounded py-2 px-4 text-sm bg-grey-lightest hover:bg-grey-lighter focus:outline-none focus:bg-white focus:border-primary-light"
        />
      </div>
      <label
        className="inline-block tracking-wide text-grey-darker text-xs font-semibold"
        htmlFor="communities-editor__course-list">
        {"Course" |> str}
      </label>
      <School__SelectBox items=courseState multiSelectCB />
      <button
        key="communities-editor__update-button"
        className="w-full bg-indigo-dark hover:bg-blue-dark text-white font-bold py-3 px-6 rounded focus:outline-none mt-3">
        {"Create a new community" |> str}
      </button>
    </DisablingCover>
  </div>;
};