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
       }
     }
   }
   `)

let groupByReaction = reactions => {
  Belt.Array.reduce(reactions, Belt.Map.String.empty, (accumulator, currentItem) => {
    let reactionValue = currentItem->Reaction.reactionValue

    switch Belt.Map.String.get(accumulator, reactionValue) {
    | Some(count) => {
        let newCount = count + 1
        Belt.Map.String.set(accumulator, reactionValue, newCount)
      }
    | None => Belt.Map.String.set(accumulator, reactionValue, 1)
    }
  })
}

@react.component
let make = (~reactionableType, ~reactionableId, ~reactions) => {
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
  let buttons = []
  let buttonClasses = "px-2 py-1 hover:bg-gray-300 hover:text-primary-500 focus:outline-none focus:bg-gray-300 focus:text-primary-500 "
  <div className="bg-white border border-gray-300 rounded-t border-b-0">
    {
      aggregatedReactions->Belt.Map.String.forEach((reactionValue, count) => {
        let buttonElement =
          <button onClick={handleAddExistingEmoji(reactionValue)}>
            {(reactionValue ++ Belt.Int.toString(count))->str}
          </button>
        buttons->Belt.Array.push(buttonElement)
      })
      React.array(buttons)
    }
    <EmojiPicker
      onChange={handleAddNewEmoji}
      className={buttonClasses ++ "border-s border-gray-400 hidden md:block"}
      title={tr("emoji_picker")}
    />
  </div>
}
