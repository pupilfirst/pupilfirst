open CoachesSchoolIndex__Types

let str = React.string

let tr = I18n.t(~scope="components.SA_Coaches_SchoolIndex")
let ts = I18n.t(~scope="shared")

type formVisible =
  | None
  | CoachEditor(option<Coach.t>)

type state = {
  coaches: list<Coach.t>,
  formVisible: formVisible,
  coachCount: int,
}

type action =
  | UpdateFormVisible(formVisible)
  | UpdateCoaches(Coach.t)
  | UpdateCoachCount(bool)

let isSelectedTabArchived = () => {
  let searchQuery = RescriptReactRouter.useUrl().search
  searchQuery |> Js.String.includes("archived")
}

let reducer = (state, action) =>
  switch action {
  | UpdateFormVisible(formVisible) => {...state, formVisible: formVisible}
  | UpdateCoaches(coach) =>
    let newCoachesList = coach |> Coach.updateList(state.coaches)
    {...state, coaches: newCoachesList}
  | UpdateCoachCount(isArchivedTabSelected) =>
    let count =
      List.filter(
        coach => Coach.archived(coach) === isArchivedTabSelected,
        state.coaches,
      )->List.length
    {...state, coachCount: count}
  }

@react.component
let make = (~coaches, ~authenticityToken) => {
  let (state, send) = React.useReducer(
    reducer,
    {coaches: coaches, formVisible: None, coachCount: Belt.List.length(coaches)},
  )

  let currentPath = "coaches?status="
  let isArchivedTabSelected = isSelectedTabArchived()

  let closeFormCB = () => send(UpdateFormVisible(None))
  let updateCoachCB = coach => {
    send(UpdateCoaches(coach))
    send(UpdateCoachCount(isArchivedTabSelected))
  }
  <div role="main" className="flex min-h-full bg-gray-50">
    {switch state.formVisible {
    | None => React.null
    | CoachEditor(coach) =>
      <SA_Coaches_CoachEditor coach closeFormCB updateCoachCB authenticityToken />
    }}
    <div className="flex-1 flex flex-col">
      <div className="w-full pt-2 relative md:sticky top-0 z-20 bg-gray-50 border-b">
        <div className="max-w-3xl mx-auto">
          <div className="px-12 flex justify-start ">
            <div
              className={`px-5 py-2 flex items-center p-2 font-medium
               ${!isArchivedTabSelected ? "border-b-2 border-primary-500 text-primary-500" : ""}`}>
              <a href={`${currentPath}active`}>
                <span className="hidden sm:inline"> {tr("active_coaches")->str} </span>
                {switch isArchivedTabSelected {
                | false =>
                  <span
                    className=`bg-primary-500 text-white text-xs leading-none rounded-md px-1.5 py-1 ms-1.5`>
                    {state.coachCount->Belt.Int.toString->str}
                  </span>
                | true => <span />
                }}
              </a>
            </div>
            <div
              className={`px-5 py-2  flex items-center p-2 font-medium
              ${isArchivedTabSelected ? "border-b-2 border-primary-500 text-primary-500" : ""}`}>
              <a href={`${currentPath}archived`}>
                <span className="hidden sm:inline"> {tr("archived_coaches")->str} </span>
                {switch isArchivedTabSelected {
                | true =>
                  <span
                    className=`bg-primary-500 text-white text-xs leading-none rounded-md px-1.5 py-1 ms-1.5`>
                    {state.coachCount->Belt.Int.toString->str}
                  </span>
                | false => <span />
                }}
              </a>
            </div>
          </div>
        </div>
      </div>
      <div className="flex px-6 py-2 items-center justify-between">
        <button
          onClick={_event => {
            ReactEvent.Mouse.preventDefault(_event)
            send(UpdateFormVisible(CoachEditor(None)))
          }}
          className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:text-primary-600 hover:shadow-lg focus:outline-none focus:shadow-lg focus:border-primary-300 focus:text-primary-600 border-2 border-primary-300 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer">
          <i className="fas fa-plus-circle text-lg" />
          <h5 className="font-semibold ms-2"> {tr("add_new_coach") |> str} </h5>
        </button>
      </div>
      <div className="px-6 pb-4 mt-5 flex flex-1">
        <div className="max-w-2xl w-full mx-auto relative">
          {state.coaches
          |> List.sort((x, y) => int_of_string(Coach.id(x)) - int_of_string(Coach.id(y)))
          |> List.filter(coach => Coach.archived(coach) === isArchivedTabSelected)
          |> List.map(coach =>
            <div
              key={coach->Coach.id}
              className="flex items-center shadow bg-white rounded-lg mb-4 overflow-hidden">
              <div className="course-faculty__list-item flex w-full">
                <button
                  ariaLabel={"Edit: " ++ (coach |> Coach.name)}
                  className="course-faculty__list-item-details flex flex-1 items-center justify-between cursor-pointer rounded-lg hover:bg-gray-50 hover:text-primary-500 focus:outline-none focus:text-primary-500 focus:bg-gray-50 focus:ring-2 focus:ring-inset focus:ring-focusColor-500"
                  onClick={_event => {
                    ReactEvent.Mouse.preventDefault(_event)
                    send(UpdateFormVisible(CoachEditor(Some(coach))))
                  }}>
                  <div className="flex flex-1 py-4 px-4">
                    <img
                      className="w-10 h-10 rounded-full me-4 object-cover"
                      src={coach |> Coach.imageUrl}
                      alt={tr("avatar_of") ++ (coach |> Coach.name)}
                    />
                    <div className="text-sm ">
                      <p className="font-semibold"> {coach |> Coach.name |> str} </p>
                      <p className="text-gray-600 text-xs mt-px"> {coach |> Coach.title |> str} </p>
                    </div>
                  </div>
                  <span
                    className="flex items-center shrink-0 ms-2 py-4 px-4 text-gray-600 hover:text-primary-500 text-sm">
                    <i className="fas fa-edit text-normal" />
                    <span className="ms-1"> {ts("edit") |> str} </span>
                  </span>
                </button>
              </div>
            </div>
          )
          |> Array.of_list
          |> React.array}
        </div>
      </div>
    </div>
  </div>
}
