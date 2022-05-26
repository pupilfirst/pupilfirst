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
  | LoadSubmissions(option<string>, bool, array<StudentInfo.t>, int)
  | BeginLoadingMore
  | BeginReloading

let reducer = (state, action) =>
  switch action {
  | UnsetSearchString => {
      ...state,
      filterInput: "",
    }
  | UpdateFilterInput(filterInput) => {...state, filterInput: filterInput}
  | LoadSubmissions(endCursor, hasNextPage, students, totalEntriesCount) =>
    let updatedStudent = switch state.loading {
    | LoadingMore => Js.Array2.concat(PagedStudents.toArray(state.students), students)
    | Reloading(_) => students
    }

    {
      ...state,
      students: PagedStudents.make(updatedStudent, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount: totalEntriesCount,
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: LoadingV2.setReloading(state.loading)}
  }

// let updateParams = filter => RescriptReactRouter.push("?" ++ Filter.toQueryString(filter))

module CourseStudentsQuery = %graphql(`
    query CourseStudentsQuery($courseId: ID!, $cohortName: String, $levelName: String, $name: String, $email: String, $after: String, $studentTags: [String!], $userTags: [String!], $sortBy: String!, $sortDirection: SortDirection!) {
      courseStudents(courseId: $courseId, cohortName: $cohortName, levelName: $levelName, name: $name, email: $email, first: 20, after: $after, studentTags: $studentTags, userTags: $userTags, sortBy: $sortBy, sortDirection: $sortDirection) {
        nodes {
          id
          taggings
          user {
            id
            name
            email
            avatarUrl
            title
            affiliation
            taggings
          }
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
    }
  `)

let getStudents = (send, courseId, cursor, filter, params) => {
  let sortBy = filter->Filter.sortByToString
  let sortDirection = filter->Filter.sortDirection

  open Webapi.Url.URLSearchParams

  let name = get("name", params)
  let email = get("email", params)
  let levelName = get("level", params)
  let cohortName = get("cohort", params)
  let userTags =
    get("user_tags", params)->Belt.Option.mapWithDefault([], u => Js.String.split(",", u))
  let studentTags =
    get("student_tags", params)->Belt.Option.mapWithDefault([], u => Js.String.split(",", u))

  CourseStudentsQuery.makeVariables(
    ~courseId,
    ~after=?cursor,
    ~sortBy,
    ~sortDirection,
    ~userTags,
    ~studentTags,
    ~name?,
    ~email?,
    ~levelName?,
    ~cohortName?,
    (),
  )
  |> CourseStudentsQuery.make
  |> Js.Promise.then_(response => {
    send(
      LoadSubmissions(
        response["courseStudents"]["pageInfo"]["endCursor"],
        response["courseStudents"]["pageInfo"]["hasNextPage"],
        Js.Array.map(StudentInfo.makeFromJS, response["courseStudents"]["nodes"]),
        response["courseStudents"]["totalCount"],
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

let reloadStudents = (courseId, filter, send, params) => {
  send(BeginReloading)
  getStudents(send, courseId, None, filter, params)
}

// let pageTitle = (courses, courseId) => {
//   let currentCourse = ArrayUtils.unsafeFind(
//     course => AppRouter__Course.id(course) == courseId,
//     "Could not find currentCourse with ID " ++ courseId ++ " in CoursesReview__Root",
//     courses,
//   )

//   `${tc("review")} | ${AppRouter__Course.name(currentCourse)}`
// }

let onSelect = (key, value, params) => {
  Webapi.Url.URLSearchParams.set(key, value, params)
  RescriptReactRouter.push("?" ++ Webapi.Url.URLSearchParams.toString(params))
}

let showTag = (~value=?, key, text, color, params) => {
  let paramsValue = Belt.Option.getWithDefault(value, text)
  <button
    key={text}
    className={"rounded-lg mt-1 mr-1 py-px px-2 text-xs font-semibold focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 " ++
    color}
    onClick={_e => onSelect(key, paramsValue, params)}>
    {text->str}
  </button>
}

let studentsList = (students, courseId, params) => {
  <div className="space-y-4">
    {students
    ->Js.Array2.map(student => {
      <div key={StudentInfo.id(student)} className="h-full flex items-center bg-white">
        <div className="flex flex-1 items-center text-left justify-between rounded-md shadow">
          <div className="flex py-4 px-4">
            <div className="text-sm flex items-center space-x-4">
              <img
                className="inline-block h-12 w-12 rounded-full"
                src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
                alt=""
              />
              <div>
                <Link
                  href={`/school/courses/${courseId}/students/${StudentInfo.id(student)}/edit`}
                  className="font-semibold inline-block hover:underline hover:text-primary-500 transition ">
                  {User.name(StudentInfo.user(student))->str}
                </Link>
                <div className="flex flex-row mt-1">
                  <div className="flex flex-wrap">
                    {showTag(
                      "cohort",
                      Cohort.name(StudentInfo.cohort(student)),
                      "bg-green-100 text-green-900",
                      params,
                    )}
                    {showTag(
                      "level",
                      Level.shortName(StudentInfo.level(student)),
                      "bg-yellow-100 text-yellow-900",
                      params,
                      ~value=Level.filterValue(StudentInfo.level(student)),
                    )}
                    {StudentInfo.taggings(student)
                    ->Js.Array2.map(tag => {
                      showTag("student_tags", tag, "bg-gray-200 text-gray-900", params)
                    })
                    ->React.array}
                    {User.taggings(StudentInfo.user(student))
                    ->Js.Array2.map(tag => {
                      showTag("user_tags", tag, "bg-blue-100 text-blue-900", params)
                    })
                    ->React.array}
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div>
            <Link
              href={`/school/courses/${courseId}/students/${StudentInfo.id(student)}/edit`}
              className="flex flex-1 items-center text-left py-4 px-4 hover:bg-gray-100 hover:text-primary-500 focus:bg-gray-100 focus:text-primary-500 justify-between">
              <span className="inline-flex items-center p-2">
                <i className="fas fa-edit text-gray-500" />
                <span className="ml-2"> {"Edit"->str} </span>
              </span>
            </Link>
          </div>
        </div>
      </div>
    })
    ->React.array}
  </div>
}

let makeFilters = () => {
  [
    CourseResourcesFilter.makeFilter("cohort", "Cohort", DataLoad(#Cohort), "green"),
    CourseResourcesFilter.makeFilter("include", "Include", Custom("Inactive Students"), "orange"),
    CourseResourcesFilter.makeFilter("level", "Level", DataLoad(#Level), "yellow"),
    CourseResourcesFilter.makeFilter(
      "student_tags",
      "Student Tags",
      DataLoad(#StudentTag),
      "indigo",
    ),
    CourseResourcesFilter.makeFilter("user_tags", "User Tags", DataLoad(#UserTag), "blue"),
    CourseResourcesFilter.makeFilter("email", "Search by Email", Search, "gray"),
    CourseResourcesFilter.makeFilter("name", "Search by Name", Search, "gray"),
  ]
}

@react.component
let make = (~courseId, ~search) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())
  let params = Webapi.Url.URLSearchParams.make(search)
  React.useEffect1(() => {
    reloadStudents(courseId, state.filter, send, params)
    None
  }, [search])

  //
  <>
    <Helmet> <title> {str("Students Index")} </title> </Helmet>
    <div>
      <div>
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
          <div className="mt-2 text-right">
            <Link
              className="btn btn-primary btn-large"
              href={`/school/courses/${courseId}/students/new`}>
              <span> {str("Create Student")} </span>
            </Link>
          </div>
          <ul className="flex font-semibold text-sm">
            <li className="px-3 py-3 md:py-2 text-primary-500 border-b-3 border-primary-500 -mb-px">
              <span> {"Active Students"->str} </span>
            </li>
          </ul>
          <div className="bg-gray-100 sticky top-0 py-3">
            <div className="border rounded-lg mx-auto bg-white ">
              <div>
                <div className="flex w-full items-start p-4">
                  <CourseResourcesFilter courseId filters={makeFilters()} search={search} />
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
                {studentsList(submissions, courseId, params)}
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
                          getStudents(send, courseId, Some(cursor), state.filter, params)
                        }}>
                        {"Load More"->str}
                      </button>
                    </div>,
                    ArrayUtils.isEmpty(times),
                  )
                }}
              </div>
            | FullyLoaded(submissions) => <div> {studentsList(submissions, courseId, params)} </div>
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
