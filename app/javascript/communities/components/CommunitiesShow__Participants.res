let str = React.string

open CommunitiesShow__Types

let avatarClasses = size => {
  let (defaultSize, mdSize) = size
  "w-" ++
  (defaultSize ++
  (" h-" ++
  (defaultSize ++
  (" md:w-" ++
  (mdSize ++
  (" md:h-" ++
  (mdSize ++
  " text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 object-cover")))))))
}

let avatar = (~size=("8", "10"), avatarUrl, name) =>
  switch avatarUrl {
  | Some(avatarUrl) => <img className={avatarClasses(size)} src=avatarUrl />
  | None => <Avatar name className={avatarClasses(size)} />
  }

@react.component
let make = (
  ~tooltipPosition=#Top,
  ~defaultAvatarSize="6",
  ~mdAvatarSize="8",
  ~title,
  ~className,
  ~participants,
  ~participantsCount,
) =>
  <div className>
    <div className="text-xs"> title </div>
    <div className="inline-flex">
      {participants
      |> Array.map(participant =>
        <Tooltip
          position=tooltipPosition
          tip={participant |> TopicParticipant.name |> str}
          className="-mr-1"
          key={participant |> TopicParticipant.id}>
          {avatar(
            ~size=(defaultAvatarSize, mdAvatarSize),
            participant |> TopicParticipant.avatarUrl,
            participant |> TopicParticipant.name,
          )}
        </Tooltip>
      )
      |> React.array}
      {
        let otherParticipantsCount = participantsCount - Js.Array.length(participants)

        otherParticipantsCount > 0
          ? <Avatar
              name={"+ " ++ (otherParticipantsCount |> string_of_int)}
              className={avatarClasses((defaultAvatarSize, mdAvatarSize))}
              colors=("#EEE", "#000")
            />
          : React.null
      }
    </div>
  </div>
