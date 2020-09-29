let str = React.string;

open CommunitiesShow__Types;

let avatarClasses = size => {
  let (defaultSize, mdSize) = size;
  "w-"
  ++ defaultSize
  ++ " h-"
  ++ defaultSize
  ++ " md:w-"
  ++ mdSize
  ++ " md:h-"
  ++ mdSize
  ++ " text-xs border border-gray-400 rounded-full overflow-hidden flex-shrink-0 object-cover";
};

let avatar = (~size=("8", "10"), avatarUrl, name) => {
  switch (avatarUrl) {
  | Some(avatarUrl) => <img className={avatarClasses(size)} src=avatarUrl />
  | None => <Avatar name className={avatarClasses(size)} />
  };
};

let creatorAvatar =
    (creator, tooltipPosition, defaultAvatarSize, mdAvatarSize) => {
  let creatorName =
    Belt.Option.mapWithDefault(creator, "Unknown", TopicParticipant.name);

  let avatarUrl =
    Belt.Option.mapWithDefault(creator, None, TopicParticipant.avatarUrl);

  let key =
    Belt.Option.mapWithDefault(creator, "unknown", TopicParticipant.id);
  <Tooltip
    position=tooltipPosition
    tip={
      creator->Belt.Option.mapWithDefault("Unknown", TopicParticipant.name)
      |> str
    }
    className="-mr-1"
    key>
    {avatar(~size=(defaultAvatarSize, mdAvatarSize), avatarUrl, creatorName)}
  </Tooltip>;
};

[@react.component]
let make =
    (
      ~tooltipPosition=`Top,
      ~defaultAvatarSize="6",
      ~mdAvatarSize="8",
      ~title,
      ~className,
      ~participants,
      ~creator,
      ~participantsCount,
    ) => {
  <div className>
    <div className="text-xs"> title </div>
    <div className="inline-flex">
      {Js.Array.concat(
         participants
         |> Array.map(participant => {
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
            }),
         [|
           creatorAvatar(
             creator,
             tooltipPosition,
             defaultAvatarSize,
             mdAvatarSize,
           ),
         |],
       )
       |> React.array}
      {let otherParticipantsCount =
         participantsCount - Js.Array.length(participants) - 1;

       otherParticipantsCount > 0
         ? <Avatar
             name={"+ " ++ (otherParticipantsCount |> string_of_int)}
             className={avatarClasses((defaultAvatarSize, mdAvatarSize))}
             colors=("#EEE", "#000")
           />
         : React.null}
    </div>
  </div>;
};
