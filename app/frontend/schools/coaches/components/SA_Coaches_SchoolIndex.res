@module("../../../../assets/images/shared/not-found.svg") external noCoachesFoundIcon: string = "default"

open CoachesSchoolIndex__Types

let str = React.string

let tr = I18n.t(~scope="components.SA_Coaches_SchoolIndex")
let ts = I18n.t(~scope="shared")

type formVisible =
  | None
  | CoachEditor(option<Coach.t>)

type state = {formVisible: formVisible}

type action = UpdateFormVisible(formVisible)

type currentTab = ActiveCoaches | ExitedCoaches

let currentTab = () => {
  Js.String.includes("exited", RescriptReactRouter.useUrl().search) ? ExitedCoaches : ActiveCoaches
}

let reducer = (_state, action) =>
  switch action {
  | UpdateFormVisible(formVisible) => {formVisible: formVisible}
  }

let coachesTab = tab => {
  let (label, currentPath) = switch tab {
  | ActiveCoaches => (tr("active_coaches"), "coaches?status=active")
  | ExitedCoaches => (tr("exited_coaches"), "coaches?status=exited")
  }
  <a
    role="tab"
    key={label}
    href={currentPath}
    className={`px-5 py-2 p-2 font-medium hover:text-primary-500 ${currentTab() == tab
        ? "border-b-2 border-primary-500 text-primary-500"
        : ""}`}>
    {label->str}
  </a>
}

@react.component
let make = (~coaches, ~authenticityToken) => {
  let (state, send) = React.useReducer(reducer, {formVisible: None})

  let closeFormCB = () => send(UpdateFormVisible(None))

  <div role="main" className="flex min-h-full bg-gray-50 pb-20">
    {switch state.formVisible {
    | None => React.null
    | CoachEditor(coach) => <SA_Coaches_CoachEditor coach closeFormCB authenticityToken />
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
              <span className="ms-2 text-sm font-medium"> {tr("add_new_coach")->str} </span>
            </button>
          </div>
        </div>
        <div className="max-w-3xl mx-auto">
          <div className="px-12 flex justify-start" role="tablist">
            {[ActiveCoaches, ExitedCoaches]->Js.Array2.map(coachesTab)->React.array}
          </div>
        </div>
      </div>
      <div className="px-6 pb-4 mt-5 flex flex-1">
        <div className="max-w-2xl w-full mx-auto relative">
          {coaches->ArrayUtils.isEmpty
            ? <div className="mt-15 pt-10">
                <img className="mx-auto h-40" src={noCoachesFoundIcon} />
                <div className=" text-center mt-14">
                  <span className="text-lg sm:text-2xl font-bold"> {tr("no_coaches")->str} </span>
                  <p className="pt-3 text-gray-500 font-medium">
                    {switch currentTab() {
                    | ActiveCoaches => tr("no_active_coaches")
                    | ExitedCoaches => tr("no_exited_coaches")
                    }->str}
                  </p>
                </div>
              </div>
            : coaches
              ->Js.Array2.map(coach =>
                <div
                  key={coach->Coach.id}
                  className="flex items-center shadow bg-white rounded-lg mb-4 overflow-hidden">
                  <div className="course-faculty__list-item flex w-full">
                    <button
                      ariaLabel={"Edit: " ++ Coach.name(coach)}
                      className="course-faculty__list-item-details flex flex-1 items-center justify-between cursor-pointer rounded-lg hover:bg-gray-50 hover:text-primary-500 focus:outline-none focus:text-primary-500 focus:bg-gray-50 focus:ring-2 focus:ring-inset focus:ring-focusColor-500"
                      onClick={_event => {
                        ReactEvent.Mouse.preventDefault(_event)
                        send(UpdateFormVisible(CoachEditor(Some(coach))))
                      }}>
                      <div className="flex flex-1 py-4 px-4">
                        <img
                          className="w-10 h-10 rounded-full me-4 object-cover"
                          src={Coach.imageUrl(coach)}
                          alt={tr("avatar_of") ++ Coach.name(coach)}
                        />
                        <div className="text-sm ">
                          <p className="font-semibold"> {Coach.name(coach)->str} </p>
                          <p className="text-gray-600 text-xs mt-px"> {Coach.title(coach)->str} </p>
                        </div>
                      </div>
                      <span
                        className="flex items-center shrink-0 ms-2 py-4 px-4 text-gray-600 hover:text-primary-500 text-sm">
                        <i className="fas fa-edit text-normal" />
                        <span className="ms-1"> {ts("edit")->str} </span>
                      </span>
                    </button>
                  </div>
                </div>
              )
              ->React.array}
        </div>
      </div>
    </div>
  </div>
}
