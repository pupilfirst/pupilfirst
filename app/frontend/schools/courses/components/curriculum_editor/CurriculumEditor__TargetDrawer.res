%%raw(`import "./CurriculumEditor__TargetDrawer.css"`)

let str = React.string

let t = I18n.t(~scope="components.CurriculumEditor__TargetDrawer")

open CurriculumEditor__Types

type page =
  | Content
  | Details
  | Versions

let confirmDirtyAction = (dirty, action) =>
  if dirty {
    WindowUtils.confirm(t("unsaved_confirm"), () => action())
  } else {
    action()
  }

let tab = (page, selectedPage, pathPrefix, dirty, setDirty) => {
  let defaultClasses = "curriculum-editor__target-drawer-tab cursor-pointer focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500"

  let (title, pathSuffix, iconClass) = switch page {
  | Content => (t("content"), "content", "fa-pen-nib")
  | Details => (t("details"), "details", "fa-list-alt")
  | Versions => (t("versions"), "versions", "fa-code-branch")
  }

  let path = pathPrefix ++ pathSuffix
  let selected = page == selectedPage

  let classes = selected
    ? defaultClasses ++ " curriculum-editor__target-drawer-tab--selected"
    : defaultClasses

  let confirm = dirty ? Some(t("unsaved_confirm")) : None

  <Link href=path ?confirm onClick={_e => setDirty(_ => false)} className=classes>
    <i className={"fas " ++ iconClass} />
    <span className="ms-2"> {title |> str} </span>
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
  ~markdownCurriculumEditorMaxLength,
) => {
  let url = RescriptReactRouter.useUrl()
  let (dirty, setDirty) = React.useState(() => false)

  React.useEffect1(() => {
    let window = Webapi.Dom.window

    let removeEventListener = () =>
      Webapi.Dom.Window.removeEventListener(window, "beforeunload", beforeWindowUnload)
    if dirty {
      Webapi.Dom.Window.addEventListener(window, "beforeunload", beforeWindowUnload)
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
          target
          hasVimeoAccessToken
          vimeoPlan
          markdownCurriculumEditorMaxLength
          setDirtyCB={dirty => setDirty(_ => dirty)}
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
      (<div> {t("unexpected_error") |> str} </div>, Content)
    }

    <SchoolAdmin__EditorDrawer
      size=SchoolAdmin__EditorDrawer.Large
      closeDrawerCB={() => confirmDirtyAction(dirty, () => closeDrawer(course))}>
      <div className="h-auto">
        <div className="bg-gray-50 pt-6">
          <div className="max-w-3xl px-3 mx-auto">
            <h3> {target |> Target.title |> str} </h3>
          </div>
          <div className="flex w-full max-w-3xl mx-auto px-3 text-sm -mb-px mt-2">
            {tab(Content, selectedPage, pathPrefix, dirty, setDirty)}
            {tab(Details, selectedPage, pathPrefix, dirty, setDirty)}
            {tab(Versions, selectedPage, pathPrefix, dirty, setDirty)}
          </div>
        </div>
        <div className="bg-white h-full">
          <div className="mx-auto border-t border-gray-300 h-full"> innerComponent </div>
        </div>
      </div>
    </SchoolAdmin__EditorDrawer>
  | _otherRoutes => React.null
  }
}
