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

module RemoveReactionMutation = %graphql(`
   mutation RemoveReactionMutation($reactionId: String!) {
     removeReaction(reactionId: $reactionId ) {
       success
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
      | Some(reaction) => {
          let existingReaction = Js.Array2.find(reactions, existingReaction =>
            existingReaction->Reaction.id === reaction->Reaction.id
          )
          Belt.Option.isNone(existingReaction)
            ? setReactions(reactions => Js.Array2.concat([reaction], reactions))
            : ()
        }
      | None => ()
      }
      Js.Promise.resolve()
    })
    |> ignore
  }

  let removeReaction = reactionValue => {
    let reactionId = Belt.Array.reduce(reactions, None, (acc, reaction) =>
      switch acc {
      | Some(_) => acc
      | None =>
        switch reaction->Reaction.reactionValue === reactionValue &&
          reaction->Reaction.userId == currentUser->CurrentUser.id {
        | true => Some(reaction->Reaction.id)
        | false => None
        }
      }
    )
    switch reactionId {
    | None => ()
    | Some(reactionId) =>
      RemoveReactionMutation.fetch({reactionId: reactionId})
      ->Js.Promise2.then((response: RemoveReactionMutation.t) => {
        if response.removeReaction.success {
          setReactions(reactions =>
            reactions->Js.Array2.filter(reaction => reaction->Reaction.id !== reactionId)
          )
        }
        Js.Promise.resolve()
      })
      ->ignore
    }
  }

  let removeReactionCB = (reactionValue, event) => {
    ReactEvent.Mouse.preventDefault(event)
    removeReaction(reactionValue)
  }

  let addReactionCB = (reactionValue, event) => {
    ReactEvent.Mouse.preventDefault(event)
    handleCreateReaction(reactionValue)
  }

  let handleAddNewEmoji = (e: EmojiPicker.emojiEvent) => {
    handleCreateReaction(e.native)
  }

  let aggregatedReactions = groupByReaction(reactions)
  let buttonClasses = "relative z-[9] px-1 md:px-2 py-0.5 md:pt-1 md:pb-0.5 flex items-center justify-center bg-white border border-gray-300 rounded-full text-gray-600 hover:text-primary-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-focusColor-500 transition "

  <div className="flex md:flex-row flex-wrap gap-1.5">
    {aggregatedReactions
    ->Belt.Map.String.toArray
    ->Belt.Array.map(((reactionValue, reactionDetails)) => {
      <CoursesCurriculum__ReactionButton
        key={reactionValue} currentUser reactionValue reactionDetails addReactionCB removeReactionCB
      />
    })
    ->React.array}
    <EmojiPicker
      onChange={handleAddNewEmoji}
      className={buttonClasses ++ "text-base md:text-lg"}
      title={tr("emoji_picker")}
    />
  </div>
}
