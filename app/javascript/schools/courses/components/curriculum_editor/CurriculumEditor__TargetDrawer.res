%bs.raw(`require("./CurriculumEditor__TargetDrawer.css")`)

let str = React.string

open CurriculumEditor__Types

type page =
  | Content
  | Details
  | Versions

let confirmDirtyAction = (dirty, action) =>
  if dirty {
    WindowUtils.confirm("There are unsaved changes. Are you sure you want to discard them?", () =>
      action()
    )
  } else {
    action()
  }

let tab = (page, selectedPage, pathPrefix, dirty, setDirty) => {
  let defaultClasses = "curriculum-editor__target-drawer-tab cursor-pointer focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"

  let (title, pathSuffix, iconClass) = switch page {
  | Content => ("Content", "content", "fa-pen-nib")
  | Details => ("Details", "details", "fa-list-alt")
  | Versions => ("Versions", "versions", "fa-code-branch")
  }

  let path = pathPrefix ++ pathSuffix
  let selected = page == selectedPage

  let classes = selected
    ? defaultClasses ++ " curriculum-editor__target-drawer-tab--selected"
    : defaultClasses

  let confirm = dirty
    ? Some("There are unsaved changes. Are you sure you want to discard them?")
    : None

  <Link href=path ?confirm onClick={_e => setDirty(_ => false)} className=classes>
    <i className={"fas " ++ iconClass} /> <span className="ml-2"> {title |> str} </span>
  </Link>
}

let closeDrawer = course =>
  RescriptReactRouter.push("/school/courses/" ++ ((course |> Course.id) ++ "/curriculum"))

let beforeWindowUnload = event => {
  event |> Webapi.Dom.Event.preventDefault
  DomUtils.Event.setReturnValue(event, "")
}

@react.component
let make = (
  ~hasVimeoAccessToken,
  ~targets,
  ~targetGroups,
  ~levels,
  ~evaluationCriteria,
  ~course,
  ~updateTargetCB,
  ~vimeoPlan,
) => {
  let url = RescriptReactRouter.useUrl()
  let (dirty, setDirty) = React.useState(() => false)

  React.useEffect1(() => {
    let window = Webapi.Dom.window

    let removeEventListener = () =>
      Webapi.Dom.Window.removeEventListener("beforeunload", beforeWindowUnload, window)
    if dirty {
      Webapi.Dom.Window.addEventListener("beforeunload", beforeWindowUnload, window)
    } else {
      removeEventListener()
    }
    Some(removeEventListener)
  }, [dirty])

  switch url.path {
  | list{"school", "courses", _courseId, "targets", targetId, pageName} =>
    let target =
      targets |> ArrayUtils.unsafeFind(
        t => t |> Target.id == targetId,
        "Could not find target for editor drawer with the ID " ++ targetId,
      )

    let pathPrefix =
      "/school/courses/" ++ ((course |> Course.id) ++ ("/targets/" ++ (targetId ++ "/")))

    let (innerComponent, selectedPage) = switch pageName {
    | "content" => (
        <CurriculumEditor__ContentEditor
          target hasVimeoAccessToken vimeoPlan setDirtyCB={dirty => setDirty(_ => dirty)}
        />,
        Content,
      )
    | "details" => (
        <CurriculumEditor__TargetDetailsEditor
          target
          targets
          targetGroups
          levels
          evaluationCriteria
          updateTargetCB
          setDirtyCB={dirty => setDirty(_ => dirty)}
        />,
        Details,
      )
    | "versions" => (<CurriculumEditor__VersionsEditor targetId />, Versions)
    | otherPage =>
      Rollbar.warning("Unexpected page requested for target editor drawer: " ++ otherPage)
      (<div> {"Unexpected error. Please reload the page." |> str} </div>, Content)
    }

    <SchoolAdmin__EditorDrawer
      size=SchoolAdmin__EditorDrawer.Large
      closeDrawerCB={() => confirmDirtyAction(dirty, () => closeDrawer(course))}>
      <div>
        <div className="bg-gray-200 pt-6">
          <div className="max-w-3xl px-3 mx-auto"> <h3> {target |> Target.title |> str} </h3> </div>
          <div className="flex w-full max-w-3xl mx-auto px-3 text-sm -mb-px mt-2">
            {tab(Content, selectedPage, pathPrefix, dirty, setDirty)}
            {tab(Details, selectedPage, pathPrefix, dirty, setDirty)}
            {tab(Versions, selectedPage, pathPrefix, dirty, setDirty)}
          </div>
        </div>
        <div className="bg-white">
          <div className="mx-auto border-t border-gray-400"> innerComponent </div>
        </div>
      </div>
    </SchoolAdmin__EditorDrawer>
  | _otherRoutes => React.null
  }
}
