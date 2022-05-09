%bs.raw(`require("./CurriculumEditor__TargetShow.css")`)

open CurriculumEditor__Types

let str = React.string

let targetClasses = (target, targets) =>
  "target-group__target flex justify-between items-center pl-2 pr-5 focus:outline-none focus:bg-gray-200 focus:text-primary-500 " ++
  switch (Js.Array.length(targets) == 1, target |> Target.visibility) {
  | (true, Archived) => "target-group__target--archived py-4 pl-5"
  | (false, Archived) => "target-group__target--archived py-4"
  | (true, _) => "py-6 pl-5"
  | (false, _) => "py-6"
  }

let updateSortIndex = (targets, target, up, updateTargetSortIndexCB) => {
  let index = Js.Array.indexOf(target, targets)
  let newTargets = up ? ArrayUtils.swapUp(index, targets) : ArrayUtils.swapDown(index, targets)

  let targetIds = newTargets |> Js.Array.map(Target.id)

  CurriculumEditor__SortResourcesMutation.sort(
    CurriculumEditor__SortResourcesMutation.Target,
    targetIds,
  )

  updateTargetSortIndexCB(newTargets)
}

let sortIndexHiddenClass = bool => bool ? " invisible" : ""

let editorLink = (linkPrefix, linkSuffix, target, iconClass) => {
  let link = linkPrefix ++ linkSuffix

  <Link
    title={"Edit " ++ (linkSuffix ++ (" of target " ++ (target |> Target.title)))}
    ariaLabel={"Edit " ++ (linkSuffix ++ (" of target " ++ (target |> Target.title)))}
    href=link
    className="curriculum-editor__target-show-quick-link text-gray-400 border-l border-transparent py-6 px-3 hover:bg-gray-200 focus:outline-none focus:bg-gray-200 focus:text-primary-500">
    <i className={"fas fa-fw " ++ iconClass} />
  </Link>
}

@react.component
let make = (~target, ~targets, ~updateTargetSortIndexCB, ~index, ~course) => {
  let linkPrefix =
    "/school/courses/" ++ ((course |> Course.id) ++ ("/targets/" ++ ((target |> Target.id) ++ "/")))

  <div
    className="flex target-group__target-container border-t bg-white overflow-hidden relative hover:bg-gray-100 hover:text-primary-500">
    {Js.Array.length(targets) > 1
      ? <div
          className="target-group__target-reorder relative flex flex-col z-10 h-full border-r border-transparent text-gray-700 justify-between items-center">
          <button
            title="Move Up"
            ariaLabel={"Move Up: "++ (target |> Target.title)}
            id={"target-move-up-" ++ (target |> Target.id)}
            className={"target-group__target-reorder-up flex items-center justify-center cursor-pointer w-9 h-9 p-1 text-gray-400 hover:bg-gray-200 focus:outline-none focus:text-primary-500" ++
            sortIndexHiddenClass(index == 0)}
            onClick={_ => updateSortIndex(targets, target, true, updateTargetSortIndexCB)}>
            <i className="fas fa-arrow-up text-sm" />
          </button>
          <button
            title="Move Down"
            ariaLabel={"Move down: " ++ (target |> Target.title)}
            id={"target-move-down-" ++ (target |> Target.id)}
            className={"target-group__target-reorder-down flex items-center justify-center cursor-pointer w-9 h-9 p-1 border-t border-transparent text-gray-400 hover:bg-gray-200 focus:outline-none focus:text-primary-500" ++
            sortIndexHiddenClass(index + 1 == Js.Array.length(targets))}
            onClick={_ => updateSortIndex(targets, target, false, updateTargetSortIndexCB)}>
            <i className="fas fa-arrow-down text-sm" />
          </button>
        </div>
      : React.null}
    <Link
      id={"target-show-" ++ (target |> Target.id)}
      title={"Edit content of target " ++ (target |> Target.title)}
      ariaLabel={"Edit content of target " ++ (target |> Target.title)}
      className={targetClasses(target, targets)}
      href={linkPrefix ++ "content"}>
      <p className="font-semibold text-sm"> {target |> Target.title |> str} </p>
      <div className="items-center">
        {switch target |> Target.visibility {
        | Draft =>
          <span
            className="target-group__target-draft-pill leading-tight text-xs py-1 px-2 font-semibold rounded-lg border bg-blue-100 text-blue-700 border-blue-400 mr-2 whitespace-nowrap">
            <i className="fas fa-file-signature text-sm" />
            <span className="ml-1"> {"Draft" |> str} </span>
          </span>
        | _ => React.null
        }}
      </div>
    </Link>
    {editorLink(linkPrefix, "details", target, "fa-list-alt")}
    {editorLink(linkPrefix, "versions", target, "fa-code-branch")}
  </div>
}
