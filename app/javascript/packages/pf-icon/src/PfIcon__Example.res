%bs.raw(`require("./PfIcon__Example.css")`)

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
    "audio-light",
    "audio-regular",
    "audio-solid",
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
    "ellipsis-light",
    "ellipsis-regular",
    "ellipsis-solid",
    "exclamation-triangle-circle-light",
    "exclamation-triangle-circle-regular",
    "exclamation-triangle-circle-solid",
    "external-link-light",
    "external-link-regular",
    "external-link-solid",
    "eye-solid",
    "file-light",
    "file-regular",
    "file-solid",
    "globe-light",
    "globe-regular",
    "globe-solid",
    "graph-up-light",
    "graph-up-regular",
    "graph-up-solid",
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
    "microphone-fill-light",
    "microphone-fill-regular",
    "microphone-fill-solid",
    "microphone-outline-light",
    "microphone-outline-regular",
    "microphone-outline-solid",
    "minus-light",
    "minus-regular",
    "minus-solid",
    "plus-circle-light",
    "plus-circle-regular",
    "plus-circle-solid",
    "plus-light",
    "plus-regular",
    "plus-solid",
    "qr-code-light",
    "qr-code-regular",
    "qr-code-solid",
    "question-circle-light",
    "question-circle-regular",
    "question-circle-solid",
    "question-square-light",
    "question-square-regular",
    "question-square-solid",
    "school-light",
    "school-regular",
    "school-solid",
    "scroll-light",
    "scroll-regular",
    "scroll-solid",
    "short-text-light",
    "short-text-regular",
    "short-text-solid",
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
    "upload-light",
    "upload-regular",
    "upload-solid",
    "user-check-light",
    "user-check-regular",
    "user-check-solid",
    "users-check-light",
    "users-check-regular",
    "users-check-solid",
    "users-light",
    "users-regular",
    "users-solid",
    "video-light",
    "video-regular",
    "video-solid",
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
    <div className="max-w-5xl mx-auto">
      <h1 className="text-center text-2xl font-bold pt-4"> {"pf-icon" |> str} </h1>
      <div>
        <div className="mt-4">
          <input
            autoComplete="off"
            value=searchString
            onChange={onChange(setSearchString)}
            type_="text"
            placeholder="Search"
            className="mx-2 text-sm bg-white border border-gray-400 rounded py-2 px-3 mt-1 focus:outline-none focus:bg-white focus:border-primary-300 appearance-none text-gray-700 focus:outline-none md:w-2/5"
          />
        </div>
        <div className="mx-2 mt-4 flex md:flex-row flex-col flex-wrap bg-white border rounded p-2">
          {switch search(searchString) {
          | [] => <div className="p-4 text-sm text-center w-full"> {"Icon not found" |> str} </div>
          | resultIcons => resultIcons |> Array.map(icon => {
              let iconClasses = "if i-" ++ icon
              <div key=icon className="flex items-center mt-4 md:w-1/2 w-full px-2 my-2">
                <PfIcon className={iconClasses ++ " if-fw text-2xl"} />
                <div className="ml-4 overflow-x-auto">
                  <div className="font-semibold text-xl"> {icon |> str} </div>
                  <div className="overflow-x-auto">
                    <code
                      className="inline-block text-gray-900 text-xs bg-red-100 p-1 mt-px whitespace-nowrap">
                      {"<PfIcon className=\"" ++ (iconClasses ++ " if-fw\" />") |> str}
                    </code>
                  </div>
                </div>
              </div>
            }) |> React.array
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
