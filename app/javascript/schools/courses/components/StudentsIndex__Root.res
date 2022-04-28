let str = React.string

open StudentsIndex__Types

module Item = {
  type t = StudentInfo.t
}

module PagedStudents = Pagination.Make(Item)

type state = {
  loading: LoadingV2.t,
  students: PagedStudents.t,
  levels: array<Level.t>,
  filterInput: string,
  totalEntriesCount: int,
  filterLoading: bool,
  filter: Filter.t,
}

type action =
  | UnsetSearchString
  | UpdateFilterInput(string)
  | LoadSubmissions(option<string>, bool, array<StudentInfo.t>, int, option<Level.t>)
  | BeginLoadingMore
  | BeginReloading

let reducer = (state, action) =>
  switch action {
  | UnsetSearchString => {
      ...state,
      filterInput: "",
    }
  | UpdateFilterInput(filterInput) => {...state, filterInput: filterInput}
  | LoadSubmissions(endCursor, hasNextPage, students, totalEntriesCount, level) =>
    let updatedStudent = switch state.loading {
    | LoadingMore => Js.Array2.concat(PagedStudents.toArray(state.students), students)
    | Reloading(_) => students
    }

    {
      ...state,
      students: PagedStudents.make(updatedStudent, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount: totalEntriesCount,
      levels: ArrayUtils.isEmpty(state.levels)
        ? Belt.Option.mapWithDefault(level, [], t => [t])
        : state.levels,
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: LoadingV2.setReloading(state.loading)}
  }

// let updateParams = filter => RescriptReactRouter.push("?" ++ Filter.toQueryString(filter))

module CourseStudentsQuery = %graphql(`
    query CourseStudentsQuery($courseId: ID!, $cohortId: ID, $levelId: ID, $search: String, $after: String, $tags: [String!], $sortBy: String!, $sortDirection: SortDirection!) {
      courseStudents(courseId: $courseId, cohortId: $cohortId, levelId: $levelId, search: $search, first: 20, after: $after, tags: $tags, sortBy: $sortBy, sortDirection: $sortDirection) {
        nodes {
          id
          name
          title
          affiliation
          avatarUrl
          taggings
          userTags
          level {
            id
            name
            number
          }
          cohort {
            id
            name
            description
            endsAt
          }
        }
        pageInfo {
          endCursor,
          hasNextPage
        }
        totalCount
      }
      level(levelId: $levelId, courseId: $courseId) {
        id
        name
        number
      }
    }
  `)

let getStudents = (send, courseId, cursor, filter) => {
  let sortBy = filter->Filter.sortByToString
  let sortDirection = filter->Filter.sortDirection
  CourseStudentsQuery.make(~courseId, ~after=?cursor, ~sortBy, ~sortDirection, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    let level = OptionUtils.map(Level.makeFromJs, response["level"])
    send(
      LoadSubmissions(
        response["courseStudents"]["pageInfo"]["endCursor"],
        response["courseStudents"]["pageInfo"]["hasNextPage"],
        Js.Array.map(StudentInfo.makeFromJS, response["courseStudents"]["nodes"]),
        response["courseStudents"]["totalCount"],
        level,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let computeInitialState = () => {
  loading: LoadingV2.empty(),
  students: Unloaded,
  levels: [],
  filterLoading: false,
  filterInput: "",
  totalEntriesCount: 0,
  filter: Filter.empty(),
}

let reloadStudents = (courseId, filter, send) => {
  send(BeginReloading)
  getStudents(send, courseId, None, filter)
}

// let pageTitle = (courses, courseId) => {
//   let currentCourse = ArrayUtils.unsafeFind(
//     course => AppRouter__Course.id(course) == courseId,
//     "Could not find currentCourse with ID " ++ courseId ++ " in CoursesReview__Root",
//     courses,
//   )

//   `${tc("review")} | ${AppRouter__Course.name(currentCourse)}`
// }

let studentsList = (submissions, state, filter) => {
  <div> {str("students x")} </div>
}

@react.component
let make = (~courseId, ~url) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())

  React.useEffect1(() => {
    reloadStudents(courseId, state.filter, send)
    None
  }, [url])

  //
  <>
    <Helmet> <title> {str("Students Index")} </title> </Helmet>
    <div role="main" ariaLabel="Review" className="flex-1 flex flex-col">
      <div>
        {str("Students Index")}
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
          <div>
            {switch state.students {
            | Unloaded =>
              <div> {SkeletonLoading.multiple(~count=6, ~element=SkeletonLoading.card())} </div>
            | PartiallyLoaded(submissions, cursor) =>
              <div>
                {studentsList(submissions, state, state.filter)}
                {switch state.loading {
                | LoadingMore =>
                  <div> {SkeletonLoading.multiple(~count=1, ~element=SkeletonLoading.card())} </div>
                | Reloading(times) =>
                  ReactUtils.nullUnless(
                    <div className="pb-6">
                      <button
                        className="btn btn-primary-ghost cursor-pointer w-full"
                        onClick={_ => {
                          send(BeginLoadingMore)
                          getStudents(send, courseId, Some(cursor), state.filter)
                        }}>
                        {"Load More"->str}
                      </button>
                    </div>,
                    ArrayUtils.isEmpty(times),
                  )
                }}
              </div>
            | FullyLoaded(submissions) =>
              <div> {studentsList(submissions, state, state.filter)} </div>
            }}
          </div>
          {switch state.students {
          | Unloaded => React.null
          | _ =>
            let loading = switch state.loading {
            | Reloading(times) => ArrayUtils.isNotEmpty(times)
            | LoadingMore => false
            }
            <LoadingSpinner loading />
          }}
        </div>
      </div>
    </div>
  </>
}
