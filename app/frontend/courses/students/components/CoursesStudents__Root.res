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
}

type action =
  | UnsetSearchString
  | UpdateFilterInput(string)
  | LoadStudents(option<string>, bool, array<StudentInfo.t>, int)
  | BeginLoadingMore
  | BeginReloading

let reducer = (state, action) =>
  switch action {
  | UnsetSearchString => {
      ...state,
      filterInput: "",
    }
  | UpdateFilterInput(filterInput) => {...state, filterInput: filterInput}
  | LoadStudents(endCursor, hasNextPage, students, totalEntriesCount) =>
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
  | BeginReloading => {
      ...state,
      loading: LoadingV2.setReloading(state.loading),
      reloadDistributionAt: Some(Js.Date.make()),
    }
  }

// Todo - Implement coach notes filter
module UserDetailsFragment = UserDetails.Fragment
module LevelFragment = Shared__Level.Fragment
module CohortFragment = Cohort.Fragment
module UserProxyFragment = UserProxy.Fragment

module StudentsQuery = %graphql(`
    query StudentsFromCoursesStudentsRootQuery($courseId: ID!, $cohortName: String, $levelName: String, $name: String, $email: String, $after: String, $studentTags: [String!], $userTags: [String!], $sortBy: String!, $sortDirection: SortDirection!) {
      courseStudents(courseId: $courseId, cohortName: $cohortName, levelName: $levelName, name: $name, email: $email, first: 20, after: $after, studentTags: $studentTags, userTags: $userTags, sortBy: $sortBy, sortDirection: $sortDirection) {
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
    }
  `)

let getStudents = (send, courseId, cursor, params) => {
  let sortBy = "name"
  let sortDirection = #Ascending

  open Webapi.Url.URLSearchParams

  let name = get("name", params)
  let email = get("email", params)
  let levelName = get("level", params)
  let cohortName = get("cohort", params)
  let userTags =
    get("user_tags", params)->Belt.Option.mapWithDefault([], u => Js.String.split(",", u))
  let studentTags =
    get("student_tags", params)->Belt.Option.mapWithDefault([], u => Js.String.split(",", u))

  StudentsQuery.makeVariables(
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
    send(
      LoadStudents(
        response.courseStudents.pageInfo.endCursor,
        response.courseStudents.pageInfo.hasNextPage,
        students,
        response.courseStudents.totalCount,
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let applicableLevels = levels => levels |> Js.Array.filter(level => Level.number(level) != 0)

// module Selectable = {
//   type t =
//     | Level(Level.t)
//     | AssignedToCoach(Coach.t, string)
//     | NameOrEmail(string)
//     | CoachNotes(bool)
//     | Tag(string)

//   let label = t =>
//     switch t {
//     | Level(level) => Some(LevelLabel.format(level |> Level.number |> string_of_int))
//     | AssignedToCoach(_) => Some(tr("assigned_to"))
//     | NameOrEmail(_) => Some(tr("name_email"))
//     | CoachNotes(_) => Some(tr("coach_notes"))
//     | Tag(_) => Some(tr("tagged_with"))
//     }

//   let value = t =>
//     switch t {
//     | Level(level) => level |> Level.name
//     | AssignedToCoach(coach, currentCoachId) =>
//       coach |> Coach.id == currentCoachId ? tr("me") : coach |> Coach.name
//     | NameOrEmail(search) => search
//     | CoachNotes(on) => on ? tr("has_notes") : tr("no_notes")
//     | Tag(tag) => tag
//     }

//   let searchString = t =>
//     switch t {
//     | Level(level) =>
//       LevelLabel.searchString(level |> Level.number |> string_of_int, level |> Level.name)
//     | AssignedToCoach(coach, currentCoachId) =>
//       if coach |> Coach.id == currentCoachId {
//         (coach |> Coach.name) ++ tr("search_assigned_me")
//       } else {
//         tr("search_assigned_to") ++ (coach |> Coach.name)
//       }
//     | NameOrEmail(search) => search
//     | CoachNotes(_) => tr("search_no_notes")
//     | Tag(tag) => tr("search_tag") ++ tag
//     }

//   let color = _t => "gray"
//   let level = level => Level(level)
//   let assignedToCoach = (coach, currentCoachId) => AssignedToCoach(coach, currentCoachId)
//   let nameOrEmail = search => NameOrEmail(search)
//   let coachNotes = on => CoachNotes(on)
//   let tag = tagString => Tag(tagString)
// }

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

let filterPlaceholder = state => tr("filter_level")

// Todo - make this a real filter

// let restoreFilterNotice = (send, currentCoach, message) =>
//   <div
//     className="mt-2 text-sm italic flex flex-col md:flex-row items-center justify-between p-3 border border-gray-300 bg-white rounded-lg">
//     <span> {message |> str} </span>
//     <button
//       className="px-2 py-1 rounded text-xs overflow-hidden border border-gray-300 bg-gray-50 text-gray-800 hover:bg-gray-300 mt-1 md:mt-0"
//       onClick={_ => send(SelectCoach(currentCoach))}>
//       {tr("assigned_me") |> str} <i className="fas fa-level-up-alt ml-2" />
//     </button>
//   </div>

// let restoreAssignedToMeFilter = (state, send, currentTeamCoach) =>
//   currentTeamCoach |> OptionUtils.mapWithDefault(currentCoach =>
//     switch state.filter.coach {
//     | None => restoreFilterNotice(send, currentCoach, tr("restore_filer_none"))
//     | Some(selectedCoach) if selectedCoach |> Coach.id == Coach.id(currentCoach) => React.null
//     | Some(selectedCoach) =>
//       restoreFilterNotice(
//         send,
//         currentCoach,
//         tr("showing_assigned") ++ ((selectedCoach |> Coach.name) ++ "."),
//       )
//     }
//   , React.null)

let computeInitialState = currentTeamCoach => {
  loading: LoadingV2.empty(),
  students: Unloaded,
  filterInput: "",
  totalEntriesCount: 0,
  reloadDistributionAt: None,
}

let reloadStudents = (courseId, params, send) => {
  send(BeginReloading)
  getStudents(send, courseId, None, params)
}

let onAddCoachNote = (courseId, params, send, ()) => {
  // switch state.filter.coachNotes {
  // | #WithCoachNotes
  // | #IgnoreCoachNotes => ()
  // | #WithoutCoachNotes => reloadStudents(courseId, state, send)
  // }
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
let make = (~levels, ~course, ~userId, ~personalCoaches, ~currentCoach, ~teamTags, ~userTags) => {
  let (currentTeamCoach, _) = React.useState(() =>
    personalCoaches->Belt.Array.some(coach => coach |> Coach.id == (currentCoach |> Coach.id))
      ? Some(currentCoach)
      : None
  )

  let (state, send) = React.useReducerWithMapState(reducer, currentTeamCoach, computeInitialState)
  let allTags = Belt.Set.String.union(teamTags, userTags)

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
        courseId
        studentId
        levels
        userId
        personalCoaches
        onAddCoachNotesCB={onAddCoachNote(courseId, params, send)}
      />
    | _ => React.null
    }}
    <div className="bg-gray-50 pt-8 pb-8 px-3 -mt-7">
      // <CoursesStudents__StudentDistribution
      //   selectLevelCB={selectLevel(levels, params)}
      //   courseId
      //   filterCoach=state.filter.coach
      //   filterCoachNotes=state.filter.coachNotes
      //   filterTags=state.filter.tags
      //   reloadAt=state.reloadDistributionAt
      // />
      <div className="w-full py-4 bg-gray-50 relative md:sticky md:top-0 z-10">
        <div className="max-w-3xl mx-auto bg-gray-50 sticky md:static md:top-0">
          // <Multiselect
          //   id="filter"
          //   unselected={unselected(
          //     levels,
          //     personalCoaches,
          //     allTags,
          //     currentCoach |> Coach.id,
          //     state,
          //   )}
          //   selected={selected(state, currentCoach |> Coach.id)}
          //   onSelect={onSelectFilter(send)}
          //   onDeselect={onDeselectFilter(send)}
          //   value=state.filterString
          //   onChange={filterString => send(UpdateFilterString(filterString))}
          //   placeholder={filterPlaceholder(state)}
          // />
          <CourseResourcesFilter courseId filters={makeFilters()} search={url.search} />
          // {restoreAssignedToMeFilter(state, send, currentTeamCoach)}
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
                    getStudents(send, courseId, Some(cursor), params)
                  }}>
                  {ts("load_more") |> str}
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
