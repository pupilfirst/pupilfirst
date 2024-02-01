let str = React.string
let tr = I18n.t(~scope="components.CoursesCurriculum__Reactions")

open CoursesCurriculum__Types

module CreateReactionMutation = %graphql(`
   mutation CreateReactionMutation($reactionValue: String!, $reactionableId: String!, $reactionableType: String! ) {
     createReaction(reactionValue: $reactionValue, reactionableId: $reactionableId, reactionableType: $reactionableType ) {
       reaction {
         id
         reactionValue
         reactionableId
         reactionableType
         userName
         userId
       }
     }
   }
   `)

let groupByReaction = reactions => {
  Belt.Array.reduce(reactions, Belt.Map.String.empty, (accumulator, currentItem) => {
    let reactionValue = currentItem->Reaction.reactionValue
    let userName = currentItem->Reaction.userName
    let userId = currentItem->Reaction.userId

    switch Belt.Map.String.get(accumulator, reactionValue) {
    | Some(reactionDetails) =>
      let newCount = reactionDetails["count"] + 1
      accumulator->Belt.Map.String.set(
        reactionValue,
        {
          "userNames": Js.Array2.concat([userName], reactionDetails["userNames"]),
          "userIds": Js.Array2.concat([userId], reactionDetails["userIds"]),
          "count": newCount,
        },
      )
    | None =>
      accumulator->Belt.Map.String.set(
        reactionValue,
        {"userNames": [userName], "userIds": [userId], "count": 1},
      )
    }
  })
}

@react.component
let make = (~currentUser, ~reactionableType, ~reactionableId, ~reactions) => {
  let (reactions, setReactions) = React.useState(() => reactions)

  let handleCreateReaction = reactionValue => {
    CreateReactionMutation.make({reactionValue, reactionableId, reactionableType})
    |> Js.Promise.then_(response => {
      switch response["createReaction"]["reaction"] {
      | Some(reaction) => setReactions(reactions => Js.Array2.concat([reaction], reactions))
      | None => ()
      }
      Js.Promise.resolve()
    })
    |> ignore
  }

  let handleAddExistingEmoji = (reactionValue, event) => {
    ReactEvent.Mouse.preventDefault(event)
    handleCreateReaction(reactionValue)
  }

  let handleAddNewEmoji = (e: EmojiPicker.emojiEvent) => {
    handleCreateReaction(e.native)
  }

  let aggregatedReactions = groupByReaction(reactions)
  let buttonClasses = "px-2 py-1 hover:bg-gray-300 hover:text-primary-500 focus:outline-none focus:bg-gray-300 focus:text-primary-500 "

  <div className="bg-white border border-gray-300 rounded-t border-b-0">
    {aggregatedReactions
    ->Belt.Map.String.toArray
    ->Belt.Array.map(((reactionValue, reactionDetails)) => {
      <CoursesCurriculum__ReactionButton
        currentUser reactionValue reactionDetails addReactionCB=handleAddExistingEmoji
      />
    })
    ->React.array}
    <EmojiPicker
      onChange={handleAddNewEmoji}
      className={buttonClasses ++ "border-s border-gray-400 hidden md:block"}
      title={tr("emoji_picker")}
    />
  </div>
}
