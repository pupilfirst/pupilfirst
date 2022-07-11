%%raw(`import "./PfIcon__Example.css"`)

@val @scope(("window", "navigator", "clipboard"))
external writeText: string => unit = "writeText"

let str = React.string

let copyAndSort = (f, t) => {
  let cp = t |> Array.copy
  cp |> Array.sort(f)
  cp
}

module Example = {
  let icons = [
    "academic-cap-light",
    "academic-cap-regular",
    "academic-cap-solid",
    "arrow-down-circle-light",
    "arrow-down-circle-regular",
    "arrow-down-circle-solid",
    "arrow-down-light",
    "arrow-down-regular",
    "arrow-down-solid",
    "arrow-left-light",
    "arrow-left-regular",
    "arrow-left-solid",
    "arrow-right-light",
    "arrow-right-regular",
    "arrow-right-short-light",
    "arrow-right-short-regular",
    "arrow-right-short-solid",
    "arrow-right-solid",
    "arrow-up-circle-light",
    "arrow-up-circle-regular",
    "arrow-up-circle-solid",
    "arrow-up-light",
    "arrow-up-regular",
    "arrow-up-solid",
    "arrows-collapse-light",
    "arrows-collapse-regular",
    "arrows-collapse-solid",
    "arrows-expand-light",
    "arrows-expand-regular",
    "arrows-expand-solid",
    "attachment-light",
    "attachment-regular",
    "attachment-solid",
    "award-light",
    "award-regular",
    "award-solid",
    "badge-check-light",
    "badge-check-regular",
    "badge-check-solid",
    "bell-light",
    "bell-regular",
    "bell-solid",
    "book-open-light",
    "book-open-regular",
    "book-open-solid",
    "briefcase-light",
    "briefcase-regular",
    "briefcase-solid",
    "calendar-light",
    "calendar-regular",
    "calendar-solid",
    "certificate-light",
    "certificate-regular",
    "certificate-solid",
    "check-circle-alt-light",
    "check-circle-alt-regular",
    "check-circle-alt-solid",
    "check-circle-light",
    "check-circle-regular",
    "check-circle-solid",
    "check-light",
    "check-regular",
    "check-solid",
    "check-square-alt-light",
    "check-square-alt-regular",
    "check-square-alt-solid",
    "check-square-light",
    "check-square-regular",
    "check-square-solid",
    "chevron-down-light",
    "chevron-down-regular",
    "chevron-down-solid",
    "chevron-left-light",
    "chevron-left-regular",
    "chevron-left-solid",
    "chevron-right-light",
    "chevron-right-regular",
    "chevron-right-solid",
    "chevron-up-light",
    "chevron-up-regular",
    "chevron-up-solid",
    "circle-light",
    "circle-regular",
    "circle-solid",
    "clipboard-check-light",
    "clipboard-check-regular",
    "clipboard-check-solid",
    "clipboard-people-light",
    "clipboard-people-regular",
    "clipboard-people-solid",
    "clock-light",
    "clock-regular",
    "clock-solid",
    "cog-light",
    "cog-regular",
    "cog-solid",
    "comment-alt-light",
    "comment-alt-regular",
    "comment-alt-solid",
    "credit-card-light",
    "credit-card-regular",
    "credit-card-solid",
    "dashed-circle-light",
    "dashed-circle-regular",
    "dashed-circle-solid",
    "default",
    "download-light",
    "download-regular",
    "download-solid",
    "edit-light",
    "edit-regular",
    "edit-solid",
    "ellipsis-light",
    "ellipsis-regular",
    "ellipsis-solid",
    "exclamation-triangle-circle-light",
    "exclamation-triangle-circle-regular",
    "exclamation-triangle-circle-solid",
    "external-link-light",
    "external-link-regular",
    "external-link-solid",
    "eye-light",
    "eye-regular",
    "eye-solid",
    "file-light",
    "file-regular",
    "file-solid",
    "file-music-light",
    "file-music-regular",
    "file-music-solid",
    "globe-light",
    "globe-regular",
    "globe-solid",
    "graph-up-light",
    "graph-up-regular",
    "graph-up-solid",
    "home-light",
    "home-regular",
    "home-solid",
    "image-auto",
    "image-fill-width",
    "image-inset-40",
    "image-inset-60",
    "image-inset-80",
    "journal-text-light",
    "journal-text-regular",
    "journal-text-solid",
    "kebab-light",
    "kebab-regular",
    "kebab-solid",
    "lamp-solid",
    "link-light",
    "link-regular",
    "link-solid",
    "long-text-light",
    "long-text-regular",
    "long-text-solid",
    "markdown-light",
    "markdown-regular",
    "markdown-solid",
    "microphone-fill-light",
    "microphone-fill-regular",
    "microphone-fill-solid",
    "microphone-outline-light",
    "microphone-outline-regular",
    "microphone-outline-solid",
    "minus-light",
    "minus-regular",
    "minus-solid",
    "music-light",
    "music-regular",
    "music-solid",
    "photo-light",
    "photo-regular",
    "photo-solid",
    "play-circle-light",
    "play-circle-regular",
    "play-circle-solid",
    "play-rectangle-light",
    "play-rectangle-regular",
    "play-rectangle-solid",
    "plus-circle-light",
    "plus-circle-regular",
    "plus-circle-solid",
    "plus-light",
    "plus-regular",
    "plus-solid",
    "power-light",
    "power-regular",
    "power-solid",
    "qr-code-light",
    "qr-code-regular",
    "qr-code-solid",
    "question-circle-light",
    "question-circle-regular",
    "question-circle-solid",
    "question-square-light",
    "question-square-regular",
    "question-square-solid",
    "redo-light",
    "redo-regular",
    "redo-solid",
    "rename-light",
    "rename-regular",
    "rename-solid",
    "school-light",
    "school-regular",
    "school-solid",
    "scroll-light",
    "scroll-regular",
    "scroll-solid",
    "short-text-light",
    "short-text-regular",
    "short-text-solid",
    "sign-in-light",
    "sign-in-regular",
    "sign-in-solid",
    "sign-out-light",
    "sign-out-regular",
    "sign-out-solid",
    "signal-1-light",
    "signal-1-regular",
    "signal-2-light",
    "signal-2-regular",
    "signal-fill-solid",
    "sort-alpha-ascending-light",
    "sort-alpha-ascending-regular",
    "sort-alpha-ascending-solid",
    "sort-alpha-descending-light",
    "sort-alpha-descending-regular",
    "sort-alpha-descending-solid",
    "sort-numeric-ascending-light",
    "sort-numeric-ascending-regular",
    "sort-numeric-ascending-solid",
    "sort-numeric-descending-light",
    "sort-numeric-descending-regular",
    "sort-numeric-descending-solid",
    "square-light",
    "square-regular",
    "square-solid",
    "stop-light",
    "stop-regular",
    "stop-solid",
    "tachometer-light",
    "tachometer-regular",
    "tachometer-solid",
    "times-circle-light",
    "times-circle-regular",
    "times-circle-solid",
    "times-light",
    "times-regular",
    "times-solid",
    "times-square-light",
    "times-square-regular",
    "times-square-solid",
    "trash-light",
    "trash-regular",
    "trash-solid",
    "undo-light",
    "undo-regular",
    "undo-solid",
    "upload-light",
    "upload-regular",
    "upload-solid",
    "user-check-light",
    "user-check-regular",
    "user-check-solid",
    "user-minus-light",
    "user-minus-regular",
    "user-minus-solid",
    "user-plus-light",
    "user-plus-regular",
    "user-plus-solid",
    "user-x-light",
    "user-x-regular",
    "user-x-solid",
    "users-check-light",
    "users-check-regular",
    "users-check-solid",
    "users-light",
    "users-regular",
    "users-solid",
    "writing-pad-solid",
  ]

  let search = searchString => {
    let normalizedString =
      searchString
      |> Js.String.trim
      |> Js.String.replaceByRe(Js.Re.fromStringWithFlags("\\s+", ~flags="g"), " ")

    switch normalizedString {
    | "" => icons
    | searchString =>
      icons
      |> Js.Array.filter(icon => icon |> String.lowercase_ascii |> Js.String.includes(searchString))
      |> copyAndSort(String.compare)
    }
  }

  let onChange = (setSearchString, event) => {
    let searchString = ReactEvent.Form.target(event)["value"]
    setSearchString(_ => searchString)
  }

  @react.component
  let make = () => {
    let (searchString, setSearchString) = React.useState(() => "")
    <div className="max-w-6xl mx-auto">
      <div className="flex items-center justify-between p-4">
        <h1 className="text-center text-2xl font-bold text-gray-700"> {"pf-icon" |> str} </h1>
        <a
          className="flex items-center cursor-pointer hover:text-gray-600"
          href="https://github.com/SVdotCO/pupilfirst/tree/master/app/frontend/packages/pf-icon"
          target="_blank">
          <img
            className="w-8 h-8"
            src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png"
          />
          <span className="pl-2"> {"Docs"->str} </span>
        </a>
      </div>
      <div className="relative">
        <div className="px-4 py-6 bg-gray-100 rounded-md sticky top-0">
          <input
            autoComplete="off"
            value=searchString
            onChange={onChange(setSearchString)}
            type_="text"
            placeholder="Search"
            className=" w-full text-sm bg-white border border-gray-400 rounded py-2 px-3 mt-1 focus:outline-none focus:bg-white focus:border-primary-300 appearance-none text-gray-700"
          />
        </div>
        <div className="grid md:grid-cols-3 gap-2 md:gap-4 flex-wrap p-4">
          {switch search(searchString) {
          | [] => <div className="p-4 text-sm text-center w-full"> {"Icon not found" |> str} </div>
          | resultIcons =>
            resultIcons
            |> Array.map(icon => {
              let iconClasses = "if i-" ++ icon
              <div key=icon className="flex items-center p-4 shadow bg-white rounded-md">
                <PfIcon className={iconClasses ++ " if-fw text-2xl"} />
                <div className="ml-4 overflow-x-auto">
                  <div className="flex gap-4 items-center justify-between">
                    <p className="font-semibold text-base"> {icon |> str} </p>
                    <button
                      onClick={_ =>
                        writeText("<PfIcon className=\"" ++ (iconClasses ++ " if-fw\" />"))}
                      className="text-xs text-gray-700 hover:text-blue-500 focus:outline-none focus:text-blue-500">
                      {"Copy"->str}
                    </button>
                  </div>
                  <div className="overflow-x-auto">
                    <code
                      className="inline-block text-gray-900 text-xs bg-red-100 p-1 mt-px whitespace-nowrap">
                      {"<PfIcon className=\"" ++ (iconClasses ++ " if-fw\" />") |> str}
                    </code>
                  </div>
                </div>
              </div>
            })
            |> React.array
          }}
        </div>
      </div>
    </div>
  }
}

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<Example />, root)
| None => ()
}
