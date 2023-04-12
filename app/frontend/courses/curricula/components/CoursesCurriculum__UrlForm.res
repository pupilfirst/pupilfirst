let str = React.string

let tr = I18n.t(~scope="components.CoursesCurriculum__UrlForm")

type state = {
  url: string,
  errors: list<string>,
}

let initialState = {url: "", errors: list{}}

type action =
  | UpdateUrl(string)
  | ResetForm

let validate = url => {
  let urlLength = url |> String.length

  if url |> UrlUtils.isInvalid(false) && urlLength > 0 {
    list{tr("url_validate_error")}
  } else {
    list{}
  }
}

let reducer = (_state, action) =>
  switch action {
  | UpdateUrl(url) => {url: url, errors: validate(url)}
  | ResetForm => initialState
  }

let updateUrl = (send, typingCB, event) => {
  let value = ReactEvent.Form.target(event)["value"] |> Js.String.trim
  typingCB(value |> String.length > 0)
  send(UpdateUrl(value))
}

let isDisabled = state =>
  switch state.url {
  | "" => true
  | _someUrl => state.errors |> ListUtils.isNotEmpty
  }

let attachUrl = (state, send, attachUrlCB, event) => {
  event |> ReactEvent.Mouse.preventDefault
  !isDisabled(state) ? attachUrlCB(state.url) : ()
  send(ResetForm)
}

@react.component
let make = (~attachUrlCB, ~typingCB) => {
  let (state, send) = React.useReducer(reducer, initialState)

  <div>
    <div className="flex items-center flex-wrap">
      <input
        id="attachment_url"
        value=state.url
        type_="text"
        placeholder=tr("button_placeholder")
        className="mt-2 cursor-pointer truncate h-10 border border-grey-400 flex px-4 items-center font-semibold rounded text-sm grow me-2"
        onChange={updateUrl(send, typingCB)}
      />
      <button
        onClick={attachUrl(state, send, attachUrlCB)}
        disabled={isDisabled(state)}
        className="mt-2 bg-focusColor-600 hover:bg-gray-500 text-white text-sm font-semibold py-2 px-6 focus:outline-none">
        {tr("button_text") |> str}
      </button>
    </div>
    {state.errors
    |> List.map(error =>
      <div className="mt-2 text-red-600 text-sm" key=error>
        <i className="fas fa-exclamation-circle me-2" /> <span> {error |> str} </span>
      </div>
    )
    |> Array.of_list
    |> React.array}
  </div>
}
