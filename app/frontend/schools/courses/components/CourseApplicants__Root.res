open CourseApplicants__Types

let t = I18n.t(~scope="components.CourseApplicants__Root")

let str = React.string

module ApplicantsQuery = %graphql(`
  query ApplicantsQuery($courseId: ID!, $search: String, $after: String, $tags: [String!], $sortCriterion: ApplicantSortCriterion!, $sortDirection: SortDirection!) {
    applicants(courseId: $courseId, tags: $tags, search: $search, first: 10, after: $after, sortCriterion: $sortCriterion,sortDirection: $sortDirection){
      nodes {
        name
        email
        tags
        id
      }
      pageInfo{
        endCursor,hasNextPage
      }
      totalCount
    }
  }
  `)

type tags = array<string>

module Item = {
  type t = Applicant.t
}

module Pagination = Pagination.Make(Item)

type sortCriterion = [#CreatedAt | #UpdatedAt | #Name]

type sortDirection = [#Ascending | #Descending]

type filter = {
  search: option<string>,
  tags: tags,
  sortCriterion: sortCriterion,
  sortDirection: sortDirection,
}

type editorAction =
  | Hidden
  | ShowForm(string)

type state = {
  loading: Loading.t,
  applicants: Pagination.t,
  filterString: string,
  filter: filter,
  totalEntriesCount: int,
  relaodApplicants: bool,
}

type action =
  | SetSearchString(string)
  | UnsetSearchString
  | ReloadApplicants
  | UpdateFilterString(string)
  | BeginLoadingMore
  | BeginReloading
  | SetTag(string)
  | ClearTag(string)
  | SetSortCriterion(sortCriterion)
  | SetSortDirection(sortDirection)
  | LoadApplicants(option<string>, bool, array<Applicant.t>, int)

let reducer = (state, action) =>
  switch action {
  | SetSearchString(string) => {
      ...state,
      filter: {
        ...state.filter,
        search: Some(string),
      },
      filterString: "",
    }
  | ReloadApplicants => {
      ...state,
      loading: Reloading,
      relaodApplicants: !state.relaodApplicants,
    }
  | UnsetSearchString => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        search: None,
      },
    }
  | UpdateFilterString(filterString) => {...state, filterString: filterString}
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: Reloading}
  | SetTag(tag) => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        tags: ArrayUtils.sort_uniq(String.compare, Js.Array.concat(state.filter.tags, [tag])),
      },
    }
  | ClearTag(tag) => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        tags: Js.Array.filter(t => t != tag, state.filter.tags),
      },
    }
  | SetSortCriterion(sortCriterion) => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        sortCriterion: sortCriterion,
      },
    }
  | SetSortDirection(sortDirection) => {
      ...state,
      filterString: "",
      filter: {
        ...state.filter,
        sortDirection: sortDirection,
      },
    }
  | LoadApplicants(endCursor, hasNextPage, newApplicants, totalEntriesCount) =>
    let applicants = switch state.loading {
    | LoadingMore => Js.Array.concat(newApplicants, Pagination.toArray(state.applicants))
    | Reloading => newApplicants
    | NotLoading => newApplicants
    }

    {
      ...state,
      applicants: Pagination.make(applicants, hasNextPage, endCursor),
      loading: NotLoading,
      totalEntriesCount: totalEntriesCount,
    }
  }

let initialState = () => {
  loading: NotLoading,
  applicants: Unloaded,
  filterString: "",
  filter: {
    search: None,
    tags: [],
    sortDirection: #Ascending,
    sortCriterion: #UpdatedAt,
  },
  totalEntriesCount: 0,
  relaodApplicants: false,
}

module Sortable = {
  type t = sortCriterion

  let criterion = c =>
    switch c {
    | #Name => t("sort_criterion.name")
    | #CreatedAt => t("sort_criterion.created_at")
    | #UpdatedAt => t("sort_criterion.updated_at")
    }

  let criterionType = c =>
    switch c {
    | #Name
    | #CreatedAt
    | #UpdatedAt =>
      #String
    }
}

module ApplicantsSorter = Sorter.Make(Sortable)

let applicantsSorter = (send, filter) =>
  <div className="ms-2 shrink-0">
    <label className="block text-tiny uppercase font-semibold"> {t("sorter.label") |> str} </label>
    <div className="mt-1">
      <ApplicantsSorter
        criteria=[#Name, #CreatedAt, #UpdatedAt]
        selectedCriterion={filter.sortCriterion}
        direction={filter.sortDirection}
        onDirectionChange={sortDirection => send(SetSortDirection(sortDirection))}
        onCriterionChange={sortCriterion => send(SetSortCriterion(sortCriterion))}
      />
    </div>
  </div>

module Selectable = {
  type t =
    | Tag(string)
    | Search(string)

  let label = s =>
    switch s {
    | Tag(_) => Some(t("filter.label.tag"))
    | Search(_) => Some(t("filter.label.search"))
    }

  let value = s =>
    switch s {
    | Tag(tag) => tag
    | Search(search) => search
    }

  let searchString = s => value(s)

  let color = t =>
    switch t {
    | Tag(_) => "gray"
    | Search(_) => "blue"
    }

  let search = search => Search(search)
  let tag = tag => Tag(tag)
}

module Multiselect = MultiselectDropdown.Make(Selectable)

let unselected = (state, tags) => {
  let trimmedFilterString = state.filterString->String.trim
  let search = trimmedFilterString == "" ? [] : [Selectable.search(trimmedFilterString)]
  let tags = Js.Array.map(s => Selectable.tag(s), tags)

  Js.Array.concat(search, tags)
}

let selected = state => {
  let tags = Js.Array.map(s => Selectable.tag(s), state.filter.tags)

  let selectedSearchString = OptionUtils.mapWithDefault(
    search => [Selectable.search(search)],
    [],
    state.filter.search,
  )

  Js.Array.concat(tags, selectedSearchString)
}

let onSelectFilter = (send, selectable) =>
  switch selectable {
  | Selectable.Tag(t) => send(SetTag(t))
  | Search(n) => send(SetSearchString(n))
  }

let onDeselectFilter = (send, selectable) =>
  switch selectable {
  | Selectable.Tag(t) => send(ClearTag(t))
  | Search(_title) => send(UnsetSearchString)
  }

let loadApplicants = (courseId, state, cursor, send) => {
  let variables = ApplicantsQuery.makeVariables(
    ~tags=?Some(state.filter.tags),
    ~sortDirection=state.filter.sortDirection,
    ~sortCriterion=state.filter.sortCriterion,
    ~after=?cursor,
    ~search=?state.filter.search,
    ~courseId,
    (),
  )
  ApplicantsQuery.make(variables)
  |> Js.Promise.then_(response => {
    let applicants = Js.Array.map(
      rawCourse => Applicant.makeFromJS(rawCourse),
      response["applicants"]["nodes"],
    )
    send(
      LoadApplicants(
        response["applicants"]["pageInfo"]["endCursor"],
        response["applicants"]["pageInfo"]["hasNextPage"],
        applicants,
        response["applicants"]["totalCount"],
      ),
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let entriesLoadedData = (totalNotificationsCount, loadedNotificaionsCount) =>
  <div className="pt-8 pb-4 mx-auto text-gray-800 text-xs px-2 text-center font-semibold">
    {(
      totalNotificationsCount == loadedNotificaionsCount
        ? t(
            ~variables=[("total_applicants", string_of_int(totalNotificationsCount))],
            "applicants_fully_loaded_text",
          )
        : t(
            ~variables=[
              ("total_applicants", string_of_int(totalNotificationsCount)),
              ("loaded_applicants_count", string_of_int(loadedNotificaionsCount)),
            ],
            "applicants_partially_loaded_text",
          )
    )->str}
  </div>

let showApplicant = (baseUrl, applicant) => {
  <div className="flex flex-1 items-center pe-4 bg-white hover:shadow border rounded">
    <button
      title={t("show_details") ++ Applicant.name(applicant)}
      className="flex flex-1 flex-col py-4 px-4 hover:bg-gray-50 cursor-pointer"
      key={Applicant.id(applicant)}
      onClick={_ => RescriptReactRouter.push(baseUrl ++ Applicant.id(applicant) ++ "/details")}>
      <div className="flex w-full items-center justify-between">
        <div className="text-black font-semibold inline-block ">
          {Applicant.name(applicant)->str}
        </div>
      </div>
      <div className="mt-1 space-x-2">
        <div className="text-xs "> {Applicant.email(applicant)->str} </div>
        {Js.Array.map(
          a => <span key=a className="p-1 text-xs bg-gray-50 rounded shadow"> {str(a)} </span>,
          Applicant.tags(applicant),
        )->React.array}
      </div>
    </button>
    <button
      title={t("show_actions") ++ ": " ++ Applicant.name(applicant)}
      className="btn btn-small btn-primary-ghost"
      onClick={_ => RescriptReactRouter.push(baseUrl ++ Applicant.id(applicant) ++ "/actions")}>
      {str(t("onboard_as_student"))}
    </button>
  </div>
}

let showApplicants = (baseUrl, applicants, state) => {
  <div className="mt-4">
    {ArrayUtils.isEmpty(applicants)
      ? <div
          className="flex flex-col mx-auto bg-white rounded-md border p-6 justify-center items-center">
          <FaIcon classes="fas fa-comments text-5xl text-gray-400" />
          <h4 className="mt-3 text-base md:text-lg text-center font-semibold">
            {t("empty_applicants")->str}
          </h4>
        </div>
      : <div className="flex flex-col space-y-2 flex-wrap">
          {Js.Array.map(applicant => showApplicant(baseUrl, applicant), applicants)->React.array}
        </div>}
    {entriesLoadedData(state.totalEntriesCount, Array.length(applicants))}
  </div>
}

let updateApplicant = (baseUrl, send, ()) => {
  RescriptReactRouter.push(baseUrl)
  send(ReloadApplicants)
}

let decodeTabString = tab => {
  switch tab {
  | "details" => CourseApplicants__EditForm.DetailsTab
  | "actions" => CourseApplicants__EditForm.ActionsTab
  | _ => CourseApplicants__EditForm.DetailsTab
  }
}

@react.component
let make = (~courseId, ~tags, ~selectedApplicant) => {
  let (state, send) = React.useReducer(reducer, initialState())
  let baseUrl = "/school/courses/" ++ courseId ++ "/applicants/"
  let url = RescriptReactRouter.useUrl()

  let (editorAction, selectedTab) = switch url.path {
  | list{"school", "courses", _courseId, "applicants", applicantId, tab, ..._} => (
      switch StringUtils.paramToId(applicantId) {
      | Some(id) => ShowForm(id)
      | None => Hidden
      },
      decodeTabString(tab),
    )

  | _ => (Hidden, CourseApplicants__EditForm.DetailsTab)
  }

  React.useEffect2(() => {
    loadApplicants(courseId, state, None, send)
    None
  }, (state.filter, state.relaodApplicants))

  <div className="flex flex-1 flex-col h-full">
    <div className="px-6 pb-4 flex-1 bg-gray-50 relative">
      <p className="mx-auto max-w-3xl pt-4 pb-3 font-semibold border-b">
        {t("applicants_page_title")->str}
      </p>
      {switch (state.applicants, editorAction) {
      | (Unloaded, _)
      | (_, Hidden) => React.null
      | (_, ShowForm(id)) => {
          let applicant = ArrayUtils.unsafeFind(
            c => Applicant.id(c) == id,
            "Unable to find applicant with ID: " ++ id ++ " in CourseApplicants__Root",
            Js.Array.concat(
              Belt.Option.mapWithDefault(selectedApplicant, [], s => [s]),
              Pagination.toArray(state.applicants),
            ),
          )
          <SchoolAdmin__EditorDrawer2 closeDrawerCB={_ => RescriptReactRouter.push(baseUrl)}>
            <CourseApplicants__EditForm
              applicant updateApplicantCB={updateApplicant(baseUrl, send)} tags selectedTab baseUrl
            />
          </SchoolAdmin__EditorDrawer2>
        }
      }}
      <div className="bg-gray-50 sticky top-0 py-3">
        <div className="border rounded-lg mx-auto max-w-3xl bg-white ">
          <div>
            <div className="flex w-full items-start p-4">
              <div className="w-full">
                <label
                  htmlFor="search_applicants"
                  className="block text-tiny font-semibold uppercase ps-px ">
                  {t("filter.input_label")->str}
                </label>
                <Multiselect
                  id="search_applicants"
                  unselected={unselected(state, tags)}
                  selected={selected(state)}
                  onSelect={onSelectFilter(send)}
                  onDeselect={onDeselectFilter(send)}
                  value=state.filterString
                  onChange={filterString => send(UpdateFilterString(filterString))}
                  placeholder={t("filter.input_placeholder")}
                />
              </div>
              {applicantsSorter(send, state.filter)}
            </div>
          </div>
        </div>
      </div>
      <div id="applicants" className="pb-4 mx-auto max-w-3xl w-full">
        {switch state.applicants {
        | Unloaded =>
          <div className="mt-8">
            {SkeletonLoading.multiple(~count=4, ~element=SkeletonLoading.card())}
          </div>
        | PartiallyLoaded(applicants, cursor) =>
          <div>
            {showApplicants(baseUrl, applicants, state)}
            {switch state.loading {
            | LoadingMore =>
              <div className="">
                {SkeletonLoading.multiple(~count=2, ~element=SkeletonLoading.card())}
              </div>
            | NotLoading =>
              <div className="px-5 pb-6">
                <button
                  className="btn btn-primary-ghost cursor-pointer w-full"
                  onClick={_ => {
                    send(BeginLoadingMore)
                    loadApplicants(courseId, state, Some(cursor), send)
                  }}>
                  {t("button_load_more")->str}
                </button>
              </div>
            | Reloading => React.null
            }}
          </div>
        | FullyLoaded(applicants) => <div> {showApplicants(baseUrl, applicants, state)} </div>
        }}
      </div>
    </div>
    {
      let loading = switch state.applicants {
      | Unloaded => false
      | _ =>
        switch state.loading {
        | NotLoading => false
        | Reloading => true
        | LoadingMore => false
        }
      }
      <LoadingSpinner loading />
    }
  </div>
}
