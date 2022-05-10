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

let showTag = (tag, color) => {
  <div key={tag} className={"rounded-lg mt-1 mr-1 py-px px-2 text-xs " ++ color}> {tag->str} </div>
}

let showtags = (tags, color) => {
  <div className="flex flex-wrap">
    {tags->Js.Array2.map(tag => {showTag(tag, color)})->React.array}
  </div>
}

let studentsList = (students, state, filter) => {
  <div className="space-y-2">
    {students
    ->Js.Array2.map(student => {
      <div className="h-full flex items-center bg-white">
        <div className="flex flex-1 items-center text-left justify-between">
          <div className="flex py-4 px-4">
            <div className="text-sm flex flex-col">
              <p className="font-semibold inline-block "> {StudentInfo.name(student)->str} </p>
              <div className="flex flex-row">
                {showtags(StudentInfo.taggings(student), "bg-gray-300 text-gray-900")}
                <div className="flex flex-wrap">
                  {showTag(Cohort.name(StudentInfo.cohort(student)), "bg-green-300 text-green-900")}
                  {showTag(
                    Level.shortName(StudentInfo.level(student)),
                    "bg-yellow-300 text-yellow-900",
                  )}
                  {StudentInfo.taggings(student)
                  ->Js.Array2.map(tag => {showTag(tag, "bg-gray-300 text-gray-900")})
                  ->React.array}
                  {StudentInfo.userTags(student)
                  ->Js.Array2.map(tag => {showTag(tag, "bg-blue-300 text-blue-900")})
                  ->React.array}
                </div>
              </div>
            </div>
          </div>
          <div>
            <button
              className="flex flex-1 items-center text-left py-4 px-4 hover:bg-gray-100 hover:text-primary-500 focus:bg-gray-100 focus:text-primary-500 justify-between">
              <span className="inline-flex items-center p-2">
                <i className="fas fa-edit text-gray-500" />
                <span className="ml-2"> {"Edit Student"->str} </span>
              </span>
            </button>
          </div>
        </div>
      </div>
    })
    ->React.array}
  </div>
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
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
          <ul className="flex font-semibold text-sm">
            <li className="px-3 py-3 md:py-2 text-primary-500 border-b-3 border-primary-500 -mb-px">
              <span> {"Active Students"->str} </span>
            </li>
          </ul>
          <div className="bg-gray-100 sticky top-0 py-3">
            <div className="border rounded-lg mx-auto bg-white ">
              <div>
                <div className="flex w-full items-start p-4">
                  <div
                    className="flex flex-wrap items-center text-sm bg-white border border-gray-400 rounded w-full py-1 px-2 mt-1 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-500">
                    <input
                      className="flex-grow appearance-none bg-transparent border-none text-gray-700 p-1.5 leading-snug focus:outline-none placeholder-gray-500"
                      placeholder="Type name, tag or level"
                      value=""
                    />
                  </div>
                  {"sorter"->str}
                </div>
              </div>
            </div>
          </div>
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
