[@bs.config {jsx: 3}];

[%bs.raw {|require("./CurriculumEditor__TargetDrawer.css")|}];

let str = React.string;

open CurriculumEditor__Types;

type page =
  | Content
  | Details
  | Versions;

let tab = (page, selectedPage, pathPrefix) => {
  let defaultClasses = "curriculum-editor__target-drawer-tab cursor-pointer";

  let (title, pathSuffix, iconClass) =
    switch (page) {
    | Content => ("Content", "content", "fa-pen-nib")
    | Details => ("Details", "details", "fa-list-alt")
    | Versions => ("Versions", "versions", "fa-code-branch")
    };

  let path = pathPrefix ++ pathSuffix;
  let selected = page == selectedPage;

  let classes =
    selected
      ? defaultClasses ++ " curriculum-editor__target-drawer-tab--selected"
      : defaultClasses;

  <a
    href=path
    onClick={e => {
      e |> ReactEvent.Mouse.preventDefault;
      ReasonReactRouter.push(path);
    }}
    className=classes>
    <FaIcon classes={"fas " ++ iconClass} />
    <span className="ml-2"> {title |> str} </span>
  </a>;
};

[@react.component]
let make =
    (~targets, ~targetGroups, ~evaluationCriteria, ~course, ~updateTargetCB) => {
  let url = ReasonReactRouter.useUrl();

  switch (url.path) {
  | ["school", "courses", _courseId, "targets", targetId, pageName] =>
    let target =
      targets
      |> ListUtils.unsafeFind(
           t => t |> Target.id == targetId,
           "Could not find target for editor drawer with the ID " ++ targetId,
         );

    let pathPrefix =
      "/school/courses/"
      ++ (course |> Course.id)
      ++ "/targets/"
      ++ targetId
      ++ "/";

    let (innerComponent, selectedPage) =
      switch (pageName) {
      | "content" => (<CurriculumEditor__ContentEditor target />, Content)
      | "details" => (
          <CurriculumEditor__TargetDetailsEditor
            target
            targets
            targetGroups
            evaluationCriteria
            updateTargetCB
          />,
          Details,
        )
      | "versions" => (
          <CurriculumEditor__VersionsEditor targetId />,
          Versions,
        )
      | otherPage =>
        Rollbar.warning(
          "Unexpected page requested for target editor drawer: " ++ otherPage,
        );
        (
          <div> {"Unexpected error. Please reload the page." |> str} </div>,
          Content,
        );
      };

    <SchoolAdmin__EditorDrawer
      size=SchoolAdmin__EditorDrawer.Large
      closeDrawerCB={() =>
        ReasonReactRouter.push(
          "/school/courses/" ++ (course |> Course.id) ++ "/curriculum",
        )
      }>
      <div>
        <div className="bg-gray-200 pt-6">
          <div className="max-w-3xl mx-auto">
            <h3> {target |> Target.title |> str} </h3>
          </div>
          <div
            className="flex w-full max-w-3xl mx-auto text-sm px-3 -mb-px mt-2">
            {tab(Content, selectedPage, pathPrefix)}
            {tab(Details, selectedPage, pathPrefix)}
            {tab(Versions, selectedPage, pathPrefix)}
          </div>
        </div>
        <div className="bg-white">
          <div className="mx-auto border-t border-gray-400">
            innerComponent
          </div>
        </div>
      </div>
    </SchoolAdmin__EditorDrawer>;
  | _otherRoutes => React.null
  };
};
