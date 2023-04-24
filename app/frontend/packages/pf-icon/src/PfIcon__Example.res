%%raw(`import "./PfIcon__Example.css"`)
@module external iconsSvg: string = "./assets/header-img.svg"
@module external pupilfirstLogo: string = "./assets/pupilfirst.svg"

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
    "alarm-light",
    "alarm-regular",
    "alarm-solid",
    "alarm-minus-light",
    "alarm-minus-regular",
    "alarm-minus-solid",
    "alarm-plus-light",
    "alarm-plus-regular",
    "alarm-plus-solid",
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
    "board-light",
    "board-regular",
    "board-solid",
    "book-bookmark-light",
    "book-bookmark-regular",
    "book-bookmark-solid",
    "book-heart-light",
    "book-heart-regular",
    "book-heart-solid",
    "book-light",
    "book-regular",
    "book-solid",
    "book-open-light",
    "book-open-regular",
    "book-open-solid",
    "book-plus-light",
    "book-plus-regular",
    "book-plus-solid",
    "bookmark-light",
    "bookmark-regular",
    "bookmark-solid",
    "bookmark-slash-light",
    "bookmark-slash-regular",
    "bookmark-slash-solid",
    "bulb-light",
    "bulb-regular",
    "bulb-solid",
    "briefcase-light",
    "briefcase-regular",
    "briefcase-solid",
    "calendar-light",
    "calendar-regular",
    "calendar-solid",
    "calendar-check-light",
    "calendar-check-regular",
    "calendar-check-solid",
    "calendar-minus-light",
    "calendar-minus-regular",
    "calendar-minus-solid",
    "calendar-plus-light",
    "calendar-plus-regular",
    "calendar-plus-solid",
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
    "circle-slash-light",
    "circle-slash-regular",
    "circle-slash-solid",
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
    "copy-light",
    "copy-regular",
    "copy-solid",
    "credit-card-light",
    "credit-card-regular",
    "credit-card-solid",
    "cup-light",
    "cup-regular",
    "cup-solid",
    "dashed-circle-light",
    "dashed-circle-regular",
    "dashed-circle-solid",
    "default",
    "desktop-monitor-light",
    "desktop-monitor-regular",
    "desktop-monitor-solid",
    "download-light",
    "download-regular",
    "download-solid",
    "drawer-light",
    "drawer-regular",
    "drawer-solid",
    "earth-web-light",
    "earth-web-regular",
    "earth-web-solid",
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
    "fire-light",
    "fire-regular",
    "fire-solid",
    "folder-light",
    "folder-regular",
    "folder-solid",
    "folder-minus-light",
    "folder-minus-regular",
    "folder-minus-solid",
    "folder-plus-light",
    "folder-plus-regular",
    "folder-plus-solid",
    "globe-light",
    "globe-regular",
    "globe-solid",
    "graph-up-light",
    "graph-up-regular",
    "graph-up-solid",
    "hash-light",
    "hash-regular",
    "hash-solid",
    "heart-light",
    "heart-regular",
    "heart-solid",
    "home-light",
    "home-regular",
    "home-solid",
    "hourglass-light",
    "hourglass-regular",
    "hourglass-solid",
    "image-auto",
    "image-fill-width",
    "image-inset-40",
    "image-inset-60",
    "image-inset-80",
    "inbox-light",
    "inbox-regular",
    "inbox-solid",
    "info-light",
    "info-regular",
    "info-solid",
    "journal-text-light",
    "journal-text-regular",
    "journal-text-solid",
    "kebab-light",
    "kebab-regular",
    "kebab-solid",
    "key-light",
    "key-regular",
    "key-solid",
    "lamp-light",
    "lamp-regular",
    "lamp-solid",
    "laptop-light",
    "laptop-regular",
    "laptop-solid",
    "link-light",
    "link-regular",
    "link-solid",
    "lock-closed-light",
    "lock-closed-regular",
    "lock-closed-solid",
    "lock-open-light",
    "lock-open-regular",
    "lock-open-solid",
    "long-text-light",
    "long-text-regular",
    "long-text-solid",
    "loop-light",
    "loop-regular",
    "loop-solid",
    "magnifier-light",
    "magnifier-regular",
    "magnifier-solid",
    "markdown-light",
    "markdown-regular",
    "markdown-solid",
    "megaphone-light",
    "megaphone-regular",
    "megaphone-solid",
    "menu-square-light",
    "menu-square-regular",
    "menu-square-solid",
    "microphone-fill-light",
    "microphone-fill-regular",
    "microphone-fill-solid",
    "microphone-outline-light",
    "microphone-outline-regular",
    "microphone-outline-solid",
    "milestone-light",
    "milestone-regular",
    "milestone-solid",
    "minus-light",
    "minus-regular",
    "minus-solid",
    "moon-crescent-light",
    "moon-crescent-regular",
    "moon-crescent-solid",
    "mouse-light",
    "mouse-regular",
    "mouse-solid",
    "music-light",
    "music-regular",
    "music-solid",
    "notebook-light",
    "notebook-regular",
    "notebook-solid",
    "pin-light",
    "pin-regular",
    "pin-solid",
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
    "refresh-light",
    "refresh-regular",
    "refresh-solid",
    "rename-light",
    "rename-regular",
    "rename-solid",
    "router-light",
    "router-regular",
    "router-solid",
    "ruler-light",
    "ruler-regular",
    "ruler-solid",
    "rupee-light",
    "rupee-regular",
    "rupee-solid",
    "scissor-light",
    "scissor-regular",
    "scissor-solid",
    "school-light",
    "school-regular",
    "school-solid",
    "scroll-light",
    "scroll-regular",
    "scroll-solid",
    "shield-light",
    "shield-regular",
    "shield-solid",
    "shield-minus-light",
    "shield-minus-regular",
    "shield-minus-solid",
    "shield-plus-light",
    "shield-plus-regular",
    "shield-plus-solid",
    "short-text-light",
    "short-text-regular",
    "short-text-solid",
    "sidebar-close-light",
    "sidebar-close-regular",
    "sidebar-close-solid",
    "sidebar-open-light",
    "sidebar-open-regular",
    "sidebar-open-solid",
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
    "star-light",
    "star-regular",
    "star-solid",
    "star-half-light",
    "star-half-regular",
    "star-half-solid",
    "star-slash-light",
    "star-slash-regular",
    "star-slash-solid",
    "sticky-note-light",
    "sticky-note-regular",
    "sticky-note-solid",
    "stop-light",
    "stop-regular",
    "stop-solid",
    "sun-light",
    "sun-regular",
    "sun-solid",
    "tachometer-light",
    "tachometer-regular",
    "tachometer-solid",
    "target-light",
    "target-regular",
    "target-solid",
    "teacher-coach-light",
    "teacher-coach-regular",
    "teacher-coach-solid",
    "thermometer-light",
    "thermometer-regular",
    "thermometer-solid",
    "thumb-down-light",
    "thumb-down-regular",
    "thumb-down-solid",
    "thumb-up-light",
    "thumb-up-regular",
    "thumb-up-solid",
    "thumbtack-light",
    "thumbtack-regular",
    "thumbtack-solid",
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
    "trophy-light",
    "trophy-regular",
    "trophy-solid",
    "undo-light",
    "undo-regular",
    "undo-solid",
    "upload-light",
    "upload-regular",
    "upload-solid",
    "user-light",
    "user-regular",
    "user-solid",
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
    "water-drop-light",
    "water-drop-regular",
    "water-drop-solid",
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
    <div className="bg-indigo-50/5">
      <div className="bg-[#EBF0FE]">
        <div className="max-w-6xl mx-auto px-5">
          <div className="flex items-center justify-between py-6">
            <img className="h-6" src={pupilfirstLogo} />
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-500 font-semibold"> {"PF-ICONS"->str} </p>
              <h1 className="text-4xl font-bold w-9/12">
                {"Beautifully crafted handmade icons."->str}
              </h1>
              <div className="flex items-center gap-5 my-8">
                <a
                  className="flex items-center gap-2 hover:underline"
                  href="https://github.com/SVdotCO/pupilfirst/tree/master/app/frontend/packages/pf-icon">
                  <svg
                    width="24"
                    height="24"
                    viewBox="0 0 24 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg">
                    <path
                      d="M15 22V18C15.1391 16.7473 14.7799 15.4901 14 14.5C17 14.5 20 12.5 20 9C20.08 7.75 19.73 6.52 19 5.5C19.28 4.35 19.28 3.15 19 2C19 2 18 2 16 3.5C13.36 3 10.64 3 8.00001 3.5C6.00001 2 5.00001 2 5.00001 2C4.70001 3.15 4.70001 4.35 5.00001 5.5C4.27188 6.51588 3.91848 7.75279 4.00001 9C4.00001 12.5 7.00001 14.5 10 14.5C9.61001 14.99 9.32001 15.55 9.15001 16.15C8.98001 16.75 8.93001 17.38 9.00001 18V22"
                      stroke="black"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                    <path
                      d="M9 18C4.49 20 4 16 2 16"
                      stroke="black"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                  <p> {"GitHub"->str} </p>
                </a>
                <a
                  className="flex items-center gap-1 hover:underline"
                  href="https://www.figma.com/file/Ea0WlsJiKszwX9lbeePdTV/PF-Icons?node-id=0%3A1&t=Xq3fNpMfjMP9F9I9-1">
                  <svg
                    width="24"
                    height="24"
                    viewBox="0 0 24 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg">
                    <path
                      d="M12 2H8.5C7.57174 2 6.6815 2.36875 6.02513 3.02513C5.36875 3.6815 5 4.57174 5 5.5C5 6.42826 5.36875 7.3185 6.02513 7.97487C6.6815 8.63125 7.57174 9 8.5 9H12M12 2V9M12 2H15.5C15.9596 2 16.4148 2.09053 16.8394 2.26642C17.264 2.44231 17.6499 2.70012 17.9749 3.02513C18.2999 3.35013 18.5577 3.73597 18.7336 4.16061C18.9095 4.58525 19 5.04037 19 5.5C19 5.95963 18.9095 6.41475 18.7336 6.83939C18.5577 7.26403 18.2999 7.64987 17.9749 7.97487C17.6499 8.29988 17.264 8.55769 16.8394 8.73358C16.4148 8.90947 15.9596 9 15.5 9H12"
                      stroke="black"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                    <path
                      d="M8.5 16C7.57174 16 6.6815 16.3687 6.02513 17.0251C5.36875 17.6815 5 18.5717 5 19.5C5 20.4283 5.36875 21.3185 6.02513 21.9749C6.6815 22.6313 7.57174 23 8.5 23C9.42826 23 10.3185 22.6313 10.9749 21.9749C11.6313 21.3185 12 20.4283 12 19.5V16M8.5 16H12M8.5 16C7.57174 16 6.6815 15.6313 6.02513 14.9749C5.36875 14.3185 5 13.4283 5 12.5C5 11.5717 5.36875 10.6815 6.02513 10.0251C6.6815 9.36875 7.57174 9 8.5 9H12V16M12 12.5C12 12.0404 12.0905 11.5852 12.2664 11.1606C12.4423 10.736 12.7001 10.3501 13.0251 10.0251C13.3501 9.70012 13.736 9.44231 14.1606 9.26642C14.5852 9.09053 15.0404 9 15.5 9C15.9596 9 16.4148 9.09053 16.8394 9.26642C17.264 9.44231 17.6499 9.70012 17.9749 10.0251C18.2999 10.3501 18.5577 10.736 18.7336 11.1606C18.9095 11.5852 19 12.0404 19 12.5C19 12.9596 18.9095 13.4148 18.7336 13.8394C18.5577 14.264 18.2999 14.6499 17.9749 14.9749C17.6499 15.2999 17.264 15.5577 16.8394 15.7336C16.4148 15.9095 15.9596 16 15.5 16C15.0404 16 14.5852 15.9095 14.1606 15.7336C13.736 15.5577 13.3501 15.2999 13.0251 14.9749C12.7001 14.6499 12.4423 14.264 12.2664 13.8394C12.0905 13.4148 12 12.9596 12 12.5Z"
                      stroke="black"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                  <p> {"Figma"->str} </p>
                </a>
              </div>
            </div>
            <div> <img className="h-64" src={iconsSvg} /> </div>
          </div>
        </div>
      </div>
      <div className=" bg-white sticky top-0">
        <div className="px-4 py-4 rounded-md max-w-6xl mx-auto">
          <input
            autoComplete="off"
            value=searchString
            onChange={onChange(setSearchString)}
            type_="text"
            placeholder="Search"
            className=" w-full text-sm bg-white border border-gray-400 rounded py-2 px-3 mt-1 focus:outline-none focus:bg-white focus:border-primary-300 appearance-none text-gray-700"
          />
        </div>
      </div>
      <div
        className="max-w-6xl mx-auto grid sm:grid-cols-2 lg:grid-cols-3 gap-2 sm:gap-4 flex-wrap p-4">
        {switch search(searchString) {
        | [] => <div className="p-4 text-sm text-center w-full"> {"Icon not found" |> str} </div>
        | resultIcons =>
          resultIcons
          |> Array.map(icon => {
            let iconClasses = "if i-" ++ icon
            <div
              key=icon
              className="flex items-center p-4 border border-gray-200 border-dashed bg-white rounded-md">
              <PfIcon className={iconClasses ++ " if-fw text-2xl"} />
              <div className="ms-4 overflow-x-auto flex-1">
                <div className="flex gap-4 items-center justify-between">
                  <p className="font-semibold text-base"> {icon |> str} </p>
                </div>
                <div className="grid grid-cols-3 gap-1 w-full">
                  <CopyButton
                    textToCopy={"<PfIcon className=\"" ++ (iconClasses ++ " if-fw\" />")}
                    label="Copy JSX"
                  />
                  <CopyButton
                    textToCopy={"<i class=\"" ++ (iconClasses ++ " if-fw\" ></i>")}
                    label="Copy HTML"
                  />
                </div>
              </div>
            </div>
          })
          |> React.array
        }}
      </div>
    </div>
  }
}

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<Example />, root)
| None => ()
}
