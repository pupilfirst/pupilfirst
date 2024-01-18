let str = React.string
let tr = I18n.t(~scope="components.CoursesCurriculum__Reactions")

open CoursesCurriculum__Types

module CreateReactionMutation = %graphql(`
   mutation CreateReactionMutation($reactionValue: String!, $submissionId: String!, $commentId: String ) {
     createReaction(reactionValue: $reactionValue, submissionId: $submissionId, commentId: $commentId ) {
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
let make = (~submission, ~reactions) => {
  let (reactions, setReactions) = React.useState(() => reactions)
  let handleCreateReaction = (submissionId, reactionValue, event) => {
    Js.log(reactionValue)
    ReactEvent.Mouse.preventDefault(event)
    let commentId = Some("")
    CreateReactionMutation.make({reactionValue, submissionId, commentId})
    |> Js.Promise.then_(response => {
      switch response["createReaction"]["reaction"] {
      | Some(reaction) => setReactions(reactions => Js.Array2.concat([reaction], reactions))
      | None => ()
      }
      Js.Promise.resolve()
    })
    |> ignore
  }
  let aggregatedReactions = groupByReaction(reactions)
  let buttons = []
  <div>
    {
      aggregatedReactions->Belt.Map.String.forEach((reactionValue, count) => {
        let buttonElement =
          <button onClick={handleCreateReaction(submission->Submission.id, reactionValue)}>
            {(reactionValue ++ Belt.Int.toString(count))->str}
          </button>
        buttons->Belt.Array.push(buttonElement)
      })
      React.array(buttons)
    }
  </div>
}
