let str = React.string

let tr = I18n.t(~scope="components.CurriculumEditor__VersionsEditor")
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
  let targetVersionId = version |> OptionUtils.map(Version.id)

  send(SetLoading)

  ContentBlock.Query.make({targetId: targetId, targetVersionId: targetVersionId})
  |> Js.Promise.then_(result => {
    let contentBlocks = result["contentBlocks"] |> Js.Array.map(ContentBlock.makeFromJs)

    let versions = result["targetVersions"] |> Version.makeArrayFromJs

    let selectedVersion = switch version {
    | Some(v) => v
    | None => versions[0]
    }
    send(LoadContent(contentBlocks, versions, selectedVersion))

    Js.Promise.resolve()
  })
  |> ignore
}

let createTargetVersion = (targetId, targetVersion, send) => {
  let targetVersionId = targetVersion |> Version.id

  send(SetLoading)

  CreateTargetVersionMutation.make({targetVersionId: targetVersionId})
  |> Js.Promise.then_(_result => {
    loadContentBlocks(targetId, send, None)
    Js.Promise.resolve()
  })
  |> ignore
}

let versionText = version =>
  <div>
    <span className="font-semibold text-lg">
      {"#" ++ ((version |> Version.number |> string_of_int) ++ " ") |> str}
    </span>
    <span className="text-xs"> {version |> Version.versionAt |> str} </span>
  </div>

let showDropdown = (versions, selectedVersion, loadContentBlocksCB) => {
  let contents =
    versions
    |> Js.Array.filter(version => version != selectedVersion)
    |> Array.map(version => {
      let id = version |> Version.id

      <button
        id
        key=id
        title={tr("select_version") ++ " " ++ id}
        onClick={_ => loadContentBlocksCB(Some(version))}
        className="whitespace-nowrap px-3 py-2 cursor-pointer hover:bg-gray-50 hover:text-primary-500 focus:outline-none focus:bg-gray-50 focus:text-primary-500 w-full ">
        {versionText(version)}
      </button>
    })

  let selected =
    <button
      title={tr("select_version") ++ " " ++ (selectedVersion |> Version.id)}
      className="text-sm appearance-none bg-white inline-flex items-center justify-between rounded focus:outline-none focus:ring-2 focus:ring-focusColor-500 hover:bg-gray-50 hover:shadow-lg px-3 h-full">
      <span> {versionText(selectedVersion)} </span>
      <span className="border-s border-gray-300 ms-2 ps-2 ">
        <i className="fas fa-chevron-down text-sm" />
      </span>
    </button>

  versions |> Array.length == 1
    ? <div className="text-sm appearance-none bg-white px-3">
        <span className="font-semibold text-lg"> {"#1 " |> str} </span>
        {selectedVersion |> Version.versionAt |> str}
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
        {(versions |> Array.length > 1 ? ts("versions") : ts("version")) |> str}
      </label>
      <HelpIcon className="ms-1" link={tr("help_url")}> {tr("help") |> str} </HelpIcon>
    </div>
    <div className="flex">
      <div className="border rounded border-gray-300 flex items-center">
        {showDropdown(versions, selectedVersion, loadContentBlocksCB)}
      </div>
      <div className="ms-2">
        <button
          className="btn btn-primary-ghost"
          onClick={_ => createTargetVersion(targetId, selectedVersion, send)}>
          {(
            selectedVersion |> Version.isLatestTargetVersion(versions)
              ? tr("save_version")
              : tr("restore_version")
          ) |> str}
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
