let str = React.string

let tr = I18n.t(~scope="components.CurriculumEditor__VersionsEditor", ...)
let ts = I18n.ts

open CurriculumEditor__Types

type rec state =
  | Loading
  | Loaded(contentBlocks, selectedVersion, versions)
and contentBlocks = array<ContentBlock.t>
and selectedVersion = Version.t
and versions = array<Version.t>

type action =
  | LoadContent(array<ContentBlock.t>, versions, selectedVersion)
  | SetLoading

let reducer = (_state, action) =>
  switch action {
  | LoadContent(contentBlocks, versions, selectedVersion) =>
    Loaded(contentBlocks, selectedVersion, versions)
  | SetLoading => Loading
  }

module CreateTargetVersionMutation = %graphql(`
   mutation CreateTargetVersionMutation($targetVersionId: ID!) {
    createTargetVersion(targetVersionId: $targetVersionId) {
       success
     }
   }
   `)

let loadContentBlocks = (targetId, send, version) => {
  let targetVersionId = OptionUtils.map(Version.id, version)

  send(SetLoading)

  ignore(Js.Promise.then_(result => {
      let contentBlocks = Js.Array.map(ContentBlock.makeFromJs, result["contentBlocks"])

      let versions = Version.makeArrayFromJs(result["targetVersions"])

      let selectedVersion = switch version {
      | Some(v) => v
      | None => versions[0]
      }
      send(LoadContent(contentBlocks, versions, selectedVersion))

      Js.Promise.resolve()
    }, ContentBlock.Query.make({targetId, targetVersionId})))
}

let createTargetVersion = (targetId, targetVersion, send) => {
  let targetVersionId = Version.id(targetVersion)

  send(SetLoading)

  ignore(Js.Promise.then_(_result => {
      loadContentBlocks(targetId, send, None)
      Js.Promise.resolve()
    }, CreateTargetVersionMutation.make({targetVersionId: targetVersionId})))
}

let versionText = version =>
  <div>
    <span className="font-semibold text-lg">
      {str("#" ++ (string_of_int(Version.number(version)) ++ " "))}
    </span>
    <span className="text-xs"> {str(Version.versionAt(version))} </span>
  </div>

let showDropdown = (versions, selectedVersion, loadContentBlocksCB) => {
  let contents = Array.map(version => {
    let id = Version.id(version)

    <button
      id
      key=id
      title={tr("select_version") ++ " " ++ id}
      onClick={_ => loadContentBlocksCB(Some(version))}
      className="whitespace-nowrap px-3 py-2 cursor-pointer hover:bg-gray-50 hover:text-primary-500 focus:outline-none focus:bg-gray-50 focus:text-primary-500 w-full ">
      {versionText(version)}
    </button>
  }, Js.Array.filter(version => version != selectedVersion, versions))

  let selected =
    <button
      title={tr("select_version") ++ " " ++ Version.id(selectedVersion)}
      className="text-sm appearance-none bg-white inline-flex items-center justify-between rounded focus:outline-none focus:ring-2 focus:ring-focusColor-500 hover:bg-gray-50 hover:shadow-lg px-3 h-full">
      <span> {versionText(selectedVersion)} </span>
      <span className="border-s border-gray-300 ms-2 ps-2 ">
        <i className="fas fa-chevron-down text-sm" />
      </span>
    </button>

  Array.length(versions) == 1
    ? <div className="text-sm appearance-none bg-white px-3">
        <span className="font-semibold text-lg"> {str("#1 ")} </span>
        {str(Version.versionAt(selectedVersion))}
      </div>
    : <Dropdown selected contents right=true className="h-full" />
}

let showContentBlocks = (
  contentBlocks,
  versions,
  selectedVersion,
  loadContentBlocksCB,
  targetId,
  send,
) =>
  <div>
    <div>
      <label className="text-xs inline-block text-gray-600 mb-1">
        {str(Array.length(versions) > 1 ? ts("versions") : ts("version"))}
      </label>
      <HelpIcon className="ms-1" link={tr("help_url")}> {str(tr("help"))} </HelpIcon>
    </div>
    <div className="flex">
      <div className="border rounded border-gray-300 flex items-center">
        {showDropdown(versions, selectedVersion, loadContentBlocksCB)}
      </div>
      <div className="ms-2">
        <button
          className="btn btn-primary-ghost"
          onClick={_ => createTargetVersion(targetId, selectedVersion, send)}>
          {str(
            Version.isLatestTargetVersion(versions, selectedVersion)
              ? tr("save_version")
              : tr("restore_version"),
          )}
        </button>
      </div>
    </div>
    <TargetContentView contentBlocks />
  </div>

@react.component
let make = (~targetId) => {
  let (state, send) = React.useReducer(reducer, Loading)

  let loadContentBlocksCB = loadContentBlocks(targetId, send)

  React.useEffect0(() => {
    loadContentBlocksCB(None)
    None
  })

  <div className="max-w-3xl py-6 px-3 mx-auto">
    {switch state {
    | Loading => SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.contents())
    | Loaded(contentBlocks, selectedVersion, versions) =>
      showContentBlocks(
        contentBlocks,
        versions,
        selectedVersion,
        loadContentBlocksCB,
        targetId,
        send,
      )
    }}
  </div>
}
