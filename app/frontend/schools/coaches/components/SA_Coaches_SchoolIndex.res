@module("./images/not-found.svg") external noCoachesFoundIcon: string = "default"

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

let isSelectedTabExited = () => {
  let searchQuery = RescriptReactRouter.useUrl().search
  searchQuery |> Js.String.includes("exited")
}

let reducer = (state, action) =>
  switch action {
  | UpdateFormVisible(formVisible) => {...state, formVisible: formVisible}
  | UpdateCoaches(coach) =>
    let newCoachesList = coach |> Coach.updateList(state.coaches)
    {...state, coaches: newCoachesList}
  }

@react.component
let make = (~coaches, ~authenticityToken) => {
  let (state, send) = React.useReducer(
    reducer,
    {coaches: coaches, formVisible: None, coachCount: Belt.List.length(coaches)},
  )

  let currentPath = "coaches?status="
  let isExitedTabSelected = isSelectedTabExited()

  let closeFormCB = () => send(UpdateFormVisible(None))
  let updateCoachCB = coach => send(UpdateCoaches(coach))

  <div role="main" className="flex min-h-full bg-gray-50">
    {switch state.formVisible {
    | None => React.null
    | CoachEditor(coach) =>
      <SA_Coaches_CoachEditor coach closeFormCB updateCoachCB authenticityToken />
    }}
    <div className="flex-1 flex flex-col">
      <div className="w-full pt-2 relative md:sticky top-0 z-20 bg-gray-50 border-b">
        <div className="max-w-3xl mx-auto">
          <div className="px-12 py-5 flex justify-between items-baseline">
            <h2 className="font-bold ms-2 text-xl"> {tr("coaches")->str} </h2>
            <button
              onClick={_event => {
                ReactEvent.Mouse.preventDefault(_event)
                send(UpdateFormVisible(CoachEditor(None)))
              }}
              className="flex items-center bg-primary-500 text-white py-3 px-6 justify-between rounded-lg text-primary-500 hover:text-white hover:shadow-lg focus:outline-none focus:shadow-lg focus:border-primary-300 focus:text-white">
              <PfIcon className="if i-plus-circle-solid if-fw" />
              <span className="ms-2 text-sm font-medium"> {tr("add_new_coach") |> str} </span>
            </button>
          </div>
        </div>
        <div className="max-w-3xl mx-auto">
          <div className="px-12 flex justify-start" role="tablist">
            <a
              role="tab"
              href={`${currentPath}active`}
              className={`flex gap-1.5 px-5 py-2 items-center p-2 font-medium hover:text-primary-500
               ${isExitedTabSelected ? "" : "border-b-2 border-primary-500 text-primary-500"}`}>
              <span> {tr("active_coaches")->str} </span>
              {switch isExitedTabSelected {
              | true => React.null
              | false =>
                <span className=`bg-primary-500 text-white text-xs rounded-md px-1.5 py-1`>
                  {state.coachCount->Belt.Int.toString->str}
                </span>
              }}
            </a>
            <a
              role="tab"
              href={`${currentPath}exited`}
              className={`flex gap-1.5 px-5 py-2 items-center p-2 font-medium hover:text-primary-500
               ${isExitedTabSelected ? "border-b-2 border-primary-500 text-primary-500" : ""}`}>
              <span className="sm:inline"> {tr("exited_coaches")->str} </span>
              {switch isExitedTabSelected {
              | true =>
                <span className=`bg-primary-500 text-white text-xs rounded-md px-1.5 py-1`>
                  {state.coachCount->Belt.Int.toString->str}
                </span>
              | false => React.null
              }}
            </a>
          </div>
        </div>
      </div>
      <div className="px-6 pb-4 mt-5 flex flex-1">
        <div className="max-w-2xl w-full mx-auto relative">
          {switch state.coaches->Belt.List.some(_ => true) {
          | true =>
            state.coaches
            |> List.filter(coach => Coach.exited(coach) === isExitedTabSelected)
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
                        <p className="text-gray-600 text-xs mt-px">
                          {coach |> Coach.title |> str}
                        </p>
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
            |> React.array
          | false =>
            <div className="mt-15 pt-10">
              <img className="mx-auto h-40" src={noCoachesFoundIcon} />
              <div className=" text-center mt-14">
                <span className="text-lg sm:text-2xl font-bold"> {tr("no_coaches")->str} </span>
                <p className="pt-3 text-gray-500 font-medium">
                  {(isExitedTabSelected ? tr("no_exited_coaches") : tr("no_active_coaches"))->str}
                </p>
              </div>
            </div>
          }}
        </div>
      </div>
    </div>
  </div>
}
