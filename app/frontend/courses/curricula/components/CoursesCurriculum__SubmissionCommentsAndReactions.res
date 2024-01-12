let str = React.string
let tr = I18n.t(~scope="components.CoursesCurriculum__SubmissionCommentsAndReactions")

open CoursesCurriculum__Types

@react.component
let make = (~submission, ~targetDetails) => {
  <div className="max-w-3xl flex items-center justify-between mx-auto">
    <div className="flex">
      <div>
        <button> {"Comment"->str} </button>
      </div>
      <div>
        {targetDetails->TargetDetails.reactions
        |> Js.Array.filter(reaction =>
          reaction |> Reaction.submissionId == (submission |> Submission.id)
        )
        |> Js.Array.map(reaction => {
          <button> {reaction->Reaction.reactionValue->str} </button>
        })
        |> React.array}
      </div>
    </div>
    <div>
      <p> {"View Comments"->str} </p>
    </div>
  </div>
}
