let str = React.string
let tr = I18n.t(~scope="components.CoursesCurriculum__ReactionButton")

open CoursesCurriculum__Types

@react.component
let make = (~currentUser, ~reactionValue, ~reactionDetails, ~addReactionCB, ~removeReactionCB) => {
  let (isHovered, setIsHovered) = React.useState(() => false)
  let currentUserReacted = reactionDetails["userIds"]->Js.Array2.includes(currentUser->User.id)

  /* Event handlers to update the hover state */
  let onMouseEnter = event => {
    ReactEvent.Mouse.preventDefault(event)
    setIsHovered(_ => true)
  }

  let onMouseLeave = event => {
    ReactEvent.Mouse.preventDefault(event)
    setIsHovered(_ => false)
  }

  <div onMouseEnter={onMouseEnter} onMouseLeave={onMouseLeave} className="flex shrink-0 ps-2">
    <button
      className="rounded-full px-2 py-1 bg-primary-100 border border-primary-300"
      onClick={switch currentUserReacted {
      | true => removeReactionCB(reactionValue)
      | false => addReactionCB(reactionValue)
      }}>
      {(reactionValue ++ " " ++ Belt.Int.toString(reactionDetails["count"]))->str}
    </button>
    {switch isHovered {
    | false => React.null
    | true =>
      <div className="modal absolute z-10 bg-white border p-2 mt-0.5 rounded-lg space-y-2">
        {reactionDetails["userNames"]
        ->Js.Array2.map(userName => {
          <div className="text-sm whitespace-nowrap text-gray-600 font-medium">
            {userName->str}
          </div>
        })
        ->React.array}
      </div>
    }}
  </div>
}
