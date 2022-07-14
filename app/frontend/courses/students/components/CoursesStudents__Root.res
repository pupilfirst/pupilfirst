%%raw(`import "./CoursesStudents__Root.css"`)

open CoursesStudents__Types

let str = React.string

let tr = I18n.t(~scope="components.CoursesStudents__Root")
let ts = I18n.t(~scope="shared")

type coachNoteFilter = [#WithCoachNotes | #WithoutCoachNotes | #IgnoreCoachNotes]

module Item = {
  type t = StudentInfo.t
}

module PagedStudents = Pagination.Make(Item)

type state = {
  loading: LoadingV2.t,
  students: PagedStudents.t,
  filterInput: string,
  totalEntriesCount: int,
  reloadDistributionAt: option<Js.Date.t>,
  studentDistribution: array<DistributionInLevel.t>,
}

type action =
  | UnsetSearchString
  | UpdateFilterInput(string)
  | LoadStudents(
      option<string>,
      bool,
      array<StudentInfo.t>,
      int,
      option<array<DistributionInLevel.t>>,
    )
  | BeginLoadingMore
  | BeginReloading

let reducer = (state, action) =>
  switch action {
  | UnsetSearchString => {
      ...state,
      filterInput: "",
    }
  | UpdateFilterInput(filterInput) => {...state, filterInput}
  | LoadStudents(endCursor, hasNextPage, students, totalEntriesCount, studentDistribution) =>
    let updatedStudent = switch state.loading {
    | LoadingMore => Js.Array2.concat(PagedStudents.toArray(state.students), students)
    | Reloading(_) => students
    }

    {
      ...state,
      students: PagedStudents.make(updatedStudent, hasNextPage, endCursor),
      loading: LoadingV2.setNotLoading(state.loading),
      totalEntriesCount,
      reloadDistributionAt: None,
      studentDistribution: Belt.Option.getWithDefault(studentDistribution, []),
    }
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {
      ...state,
      loading: LoadingV2.setReloading(state.loading),
      reloadDistributionAt: Some(Js.Date.make()),
    }
  }

module UserDetailsFragment = UserDetails.Fragment
module LevelFragment = Shared__Level.Fragment
module CohortFragment = Cohort.Fragment
module UserProxyFragment = UserProxy.Fragment

module StudentsQuery = %graphql(`
    query StudentsFromCoursesStudentsRootQuery($courseId: ID!, $after: String, $filterString: String, $skipIfLoadingMore: Boolean!) {
      courseStudents(courseId: $courseId, filterString: $filterString, first: 20, after: $after, ) {
        nodes {
          id,
          taggings
          user {
            ...UserDetailsFragment
          }
          level {
            ...LevelFragment
          }
          cohort {
            ...CohortFragment
          }
          personalCoaches {
            ...UserProxyFragment
          }
          accessEndsAt
          droppedOutAt
        }
        pageInfo{
          endCursor,hasNextPage
        }
        totalCount
      }
      studentDistribution(courseId: $courseId, filterString: $filterString) @skip(if: $skipIfLoadingMore) {
        id
        number
        filterName
        studentsInLevel
        unlocked
      }
    }
  `)

let getStudents = (send, courseId, cursor, ~loadingMore=false, params) => {
  let filterString = Webapi.Url.URLSearchParams.toString(params)

  StudentsQuery.makeVariables(
    ~courseId,
    ~after=?cursor,
    ~filterString=?Some(filterString),
    ~skipIfLoadingMore={loadingMore},
    (),
  )
  |> StudentsQuery.fetch
  |> Js.Promise.then_((response: StudentsQuery.t) => {
    let nodes = response.courseStudents.nodes
    let students =
      nodes->Js.Array2.map(s =>
        StudentInfo.make(
          ~id=s.id,
          ~taggings=s.taggings,
          ~user=UserDetails.makeFromFragment(s.user),
          ~level=Shared__Level.makeFromFragment(s.level),
          ~cohort=Cohort.makeFromFragment(s.cohort),
          ~accessEndsAt=s.accessEndsAt->Belt.Option.map(DateFns.decodeISO),
          ~droppedOutAt=s.droppedOutAt->Belt.Option.map(DateFns.decodeISO),
          ~personalCoaches=s.personalCoaches->Js.Array2.map(UserProxy.makeFromFragment),
        )
      )

    let studentDistribution =
      response.studentDistribution->Belt.Option.map(p =>
        p->Js.Array2.map(
          d =>
            DistributionInLevel.make(
              ~id=d.id,
              ~number=d.number,
              ~studentsInLevel=d.studentsInLevel,
              ~unlocked=d.unlocked,
              ~filterName=d.filterName,
            ),
        )
      )
    send(
      LoadStudents(
        response.courseStudents.pageInfo.endCursor,
        response.courseStudents.pageInfo.hasNextPage,
        students,
        response.courseStudents.totalCount,
        studentDistribution,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let applicableLevels = levels => levels |> Js.Array.filter(level => Level.number(level) != 0)

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

let computeInitialState = () => {
  loading: LoadingV2.empty(),
  students: Unloaded,
  filterInput: "",
  totalEntriesCount: 0,
  reloadDistributionAt: None,
  studentDistribution: [],
}

let reloadStudents = (courseId, params, send) => {
  send(BeginReloading)
  getStudents(send, courseId, None, params)
}

let onAddCoachNote = (courseId, params, send, ()) => {
  reloadStudents(courseId, params, send)
}

let onSelect = (key, value, params) => {
  Webapi.Url.URLSearchParams.set(key, value, params)
  RescriptReactRouter.push("?" ++ Webapi.Url.URLSearchParams.toString(params))
}

let selectLevel = (levels, params, levelId) => {
  let level =
    levels |> ArrayUtils.unsafeFind(level => Level.id(level) == levelId, tr("not_found") ++ levelId)

  onSelect("level", level->Level.name, params)
}

@react.component
let make = (~levels, ~course, ~userId) => {
  let (state, send) = React.useReducer(reducer, computeInitialState())

  let courseId = course |> Course.id

  let url = RescriptReactRouter.useUrl()
  let params = Webapi.Url.URLSearchParams.make(url.search)

  React.useEffect1(() => {
    reloadStudents(courseId, params, send)
    None
  }, [url.search])

  <div role="main" ariaLabel="Students">
    {switch url.path {
    | list{"students", studentId, "report"} =>
      <CoursesStudents__StudentOverlay
        courseId studentId levels userId onAddCoachNotesCB={onAddCoachNote(courseId, params, send)}
      />
    | _ => React.null
    }}
    <div className="bg-gray-50 pt-8 pb-8 px-3 -mt-7">
      <CoursesStudents__StudentDistribution
        params={params} studentDistribution={state.studentDistribution}
      />
      <div className="w-full py-4 bg-gray-50 relative md:sticky md:top-0 z-10">
        <div className="max-w-3xl mx-auto bg-gray-50 sticky md:static md:top-0">
          <CourseResourcesFilter courseId filters={makeFilters()} search={url.search} />
        </div>
      </div>
      <div className=" max-w-3xl mx-auto">
        {switch state.students {
        | Unloaded => SkeletonLoading.multiple(~count=10, ~element=SkeletonLoading.userCard())
        | PartiallyLoaded(students, cursor) =>
          <div>
            <CoursesStudents__StudentsList students />
            {switch state.loading {
            | LoadingMore => SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
            | Reloading(times) =>
              ReactUtils.nullUnless(
                <button
                  className="btn btn-primary-ghost cursor-pointer w-full mt-4"
                  onClick={_ => {
                    send(BeginLoadingMore)
                    getStudents(send, courseId, Some(cursor), params, ~loadingMore=true)
                  }}>
                  {ts("load_more")->str}
                </button>,
                ArrayUtils.isEmpty(times),
              )
            }}
          </div>
        | FullyLoaded(students) => <CoursesStudents__StudentsList students />
        }}
      </div>
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
}
