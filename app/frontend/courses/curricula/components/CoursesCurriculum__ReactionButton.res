let str = React.string
let tr = I18n.t(~scope="components.CoursesCurriculum__ReactionButton")

open CoursesCurriculum__Types

@react.component
let make = (~currentUser, ~reactionValue, ~reactionDetails, ~addReactionCB, ~removeReactionCB) => {
  let (isHovered, setIsHovered) = React.useState(() => false)
  let currentUserReacted =
    reactionDetails["userIds"]->Js.Array2.includes(currentUser->CurrentUser.id)

  /* Event handlers to update the hover state */
  let onMouseEnter = event => {
    ReactEvent.Mouse.preventDefault(event)
    setIsHovered(_ => true)
  }

  let onMouseLeave = event => {
    ReactEvent.Mouse.preventDefault(event)
    setIsHovered(_ => false)
  }

  <div onMouseEnter={onMouseEnter} onMouseLeave={onMouseLeave} className="flex shrink-0">
    <button
      className={`rounded-full flex items-center space-x-1 relative px-1 md:px-2 py-0.5 border focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-focusColor-500 transition " ${currentUserReacted
          ? "bg-primary-100 border-primary-300"
          : "bg-gray-100 border-gray-300"} hover:text-primary-500 hover:border-primary-500 hover:bg-gray-100 transition`}
      onClick={currentUserReacted ? removeReactionCB(reactionValue) : addReactionCB(reactionValue)}>
      <span className="text-xs"> {reactionValue->str} </span>
      <span className="text-xs md:text-sm">
        {Belt.Int.toString(reactionDetails["count"])->str}
      </span>
    </button>
    {isHovered
      ? <div
          className="modal absolute z-10 bg-gray-950 text-gray-400 border p-2 mt-9 rounded space-y-1">
          {reactionDetails["userNames"]
          ->Js.Array2.map(userName => {
            <div key={userName} className="text-xs whitespace-nowrap font-medium">
              {userName->str}
            </div>
          })
          ->React.array}
        </div>
      : React.null}
  </div>
}
