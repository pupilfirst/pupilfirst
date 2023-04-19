open CoursesCurriculum__Types

let t = I18n.t(~scope="components.CoursesCurriculum__LevelUpButton")
let str = React.string

let handleSubmitButton = saving => {
  let submitButtonText = (title, iconClasses) =>
    <span> <FaIcon classes={iconClasses ++ " me-2"} /> {title |> str} </span>

  saving
    ? submitButtonText(t("button_text_saving"), "fas fa-spinner fa-spin")
    : submitButtonText(t("button_text_level_up"), "fas fa-flag")
}

let refreshPage = () => {
  open Webapi.Dom
  location |> Location.reload
}

@react.component
let make = (~course) => {
  let (saving, setSaving) = React.useState(() => false)
  <button disabled=saving className="btn btn-success btn-large w-full md:w-2/3 mt-4">
    {handleSubmitButton(saving)}
  </button>
}
