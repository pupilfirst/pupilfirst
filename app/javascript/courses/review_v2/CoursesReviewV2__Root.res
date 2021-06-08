let str = React.string

@bs.module
external reviewedEmptyImage: string = "../../shared/images/reviewed-empty.svg"
@bs.module
external pendingEmptyImage: string = "../images/pending-empty.svg"

open CoursesReview__Types

let str = React.string

type state =
  | Loading
  | Reloading
  | Loaded

module SubmissionsQuery = %graphql(
  `
    query SubmissionsQuery($courseId: ID!, $status: SubmissionStatus!, $sortDirection: SortDirection!,$sortCriterion: SubmissionSortCriterion!, $levelId: ID, $coachId: ID, $after: String) {
      submissions(courseId: $courseId, status: $status, sortDirection: $sortDirection, sortCriterion: $sortCriterion, levelId: $levelId, coachId: $coachId, first: 20, after: $after) {
        nodes {
          id,
          title,
          userNames,
          evaluatedAt,
          passedAt,
          feedbackSent,
          levelId,
          createdAt,
          targetId,
          coachIds,
          teamName
        }
        pageInfo {
          endCursor,
          hasNextPage
        }
        totalCount
      }
    }
  `
)

// let getSubmissions = (
//   courseId,
//   cursor,
//   setState,
//   selectedLevel,
//   selectedCoach,
//   sortBy,
//   selectedTab,
//   submissions,
//   updateSubmissionsCB,
// ) => {
//   setState(state =>
//     switch state {
//     | Loaded
//     | Reloading =>
//       Reloading
//     | Loading => Loading
//     }
//   )

//   let levelId = selectedLevel |> OptionUtils.map(level => level |> Level.id)
//   let coachId = selectedCoach |> OptionUtils.map(coach => coach |> Coach.id)
//   let sortDirection = SubmissionsSorting.sortDirection(sortBy)
//   let sortCriterion = SubmissionsSorting.sortCriterion(sortBy)
//   SubmissionsQuery.make(
//     ~courseId,
//     ~status=selectedTab,
//     ~sortDirection,
//     ~sortCriterion,
//     ~levelId?,
//     ~coachId?,
//     ~after=?cursor,
//     (),
//   )
//   |> GraphqlQuery.sendQuery
//   |> Js.Promise.then_(response => {
//     response["submissions"]["nodes"] |> updateSubmissions(
//       setState,
//       response["submissions"]["pageInfo"]["endCursor"],
//       response["submissions"]["pageInfo"]["hasNextPage"],
//       response["submissions"]["totalCount"],
//       submissions,
//       selectedTab,
//       updateSubmissionsCB,
//     )
//     Js.Promise.resolve()
//   })
//   |> ignore
// }

@react.component
let make = (~courseId) => {
  let (state, setState) = React.useState(() => Loading)
  // getSubmissions(
  //   courseId,
  //   None,
  //   setState,
  //   selectedLevel,
  //   selectedCoach,
  //   sortBy,
  //   selectedTab,
  //   [],
  //   updateSubmissionsCB,
  // )
  let url = RescriptReactRouter.useUrl()

  <div>
    {switch url.path {
    | list{"submissions", submissionId, "review_v2"} =>
      <CoursesReviewV2__SubmissionOverlay submissionId />
    | _ => React.null
    }}
    <div className="bg-gray-100 pt-9 pb-8 px-3 -mt-7">
      <div>
        <LoadingSpinner loading={state == Reloading} />
        // {switch (submissions: Submissions.t) {
        // | Unloaded => SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.card())
        // | PartiallyLoaded({submissions}, cursor) =>
        //   <div>
        //     {showSubmissions(submissions, selectedTab, levels)}
        //     {state == Loading
        //       ? SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
        //       : <button
        //           className="btn btn-primary-ghost cursor-pointer w-full mt-4"
        //           onClick={_ => {
        //             setState(_state => Loading)
        //             getSubmissions(
        //               courseId,
        //               Some(cursor),
        //               setState,
        //               selectedLevel,
        //               selectedCoach,
        //               sortBy,
        //               selectedTab,
        //               submissions,
        //               updateSubmissionsCB,
        //             )
        //           }}>
        //           {"Load More..." |> str}
        //         </button>}
        //   </div>
        // | FullyLoaded({submissions}) => showSubmissions(submissions, selectedTab, levels)
        // }}
      </div>
    </div>
  </div>
}
