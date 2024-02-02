let str = React.string
let tr = I18n.t(~scope="components.CoursesCurriculum__ReactionButton")

open CoursesCurriculum__Types

@react.component
let make = (~currentUser, ~reactionValue, ~reactionDetails, ~addReactionCB) => {
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

  <div>
    <button
      onClick={addReactionCB(reactionValue)}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}>
      {(reactionValue ++ Belt.Int.toString(reactionDetails["count"]))->str}
    </button>
    {switch isHovered {
    | false => React.null
    | true =>
      <div className="modal">
        {reactionDetails["userNames"]
        ->Js.Array2.map(userName => {<li> {userName->str} </li>})
        ->React.array}
      </div>
    }}
  </div>
}
