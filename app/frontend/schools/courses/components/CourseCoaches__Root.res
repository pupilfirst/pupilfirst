open CourseCoaches__Types

let str = React.string

let t = I18n.t(~scope="components.CourseCoaches__Root")
let ts = I18n.ts

type formVisible =
  | None
  | CoachEnrollmentForm
  | CoachInfoForm(CourseCoach.t)

type state = {
  courseCoaches: array<CourseCoach.t>,
  formVisible: formVisible,
  saving: bool,
}

type action =
  | UpdateFormVisible(formVisible)
  | AddCourseCoaches(array<CourseCoach.t>)
  | RemoveCoach(string)
  | UpdateSaving

let reducer = (state, action) =>
  switch action {
  | UpdateFormVisible(formVisible) => {...state, formVisible}
  | AddCourseCoaches(courseCoaches) => {
      ...state,
      courseCoaches: state.courseCoaches |> Array.append(courseCoaches),
    }
  | RemoveCoach(coachId) => {
      ...state,
      courseCoaches: state.courseCoaches |> Js.Array.filter(courseCoach =>
        CourseCoach.id(courseCoach) !== coachId
      ),
    }
  | UpdateSaving => {...state, saving: !state.saving}
  }

let handleErrorCB = (send, ()) => {
  send(UpdateSaving)
  Notification.error(
    t("enrollment_delete_error_head_notification"),
    t("enrollment_delete_error_notification_body"),
  )
}

let handleResponseCB = (send, json) => {
  send(UpdateSaving)
  let coachId = json |> {
    open Json.Decode
    field("coach_id", string)
  }
  send(RemoveCoach(coachId))
  Notification.success(ts("notifications.success"), t("enrollment_delete_notificaion_success_body"))
}

let removeCoach = (send, courseId, authenticityToken, coach, event) => {
  event |> ReactEvent.Mouse.preventDefault

  if {
    open Webapi.Dom
    window->Window.confirm(
      t("remove_confirm_pre") ++
      " " ++
      ((coach |> CourseCoach.name) ++
      " " ++
      t("remove_confirm_post")),
    )
  } {
    send(UpdateSaving)
    let url = "/school/courses/" ++ (courseId ++ "/delete_coach_enrollment")
    let payload = Js.Dict.empty()
    Js.Dict.set(payload, "authenticity_token", authenticityToken |> Js.Json.string)
    Js.Dict.set(payload, "coach_id", coach |> CourseCoach.id |> Js.Json.string)
    Api.create(url, payload, handleResponseCB(send), handleErrorCB(send))
  } else {
    ()
  }
}

@react.component
let make = (~courseCoaches, ~schoolCoaches, ~courseId, ~authenticityToken) => {
  let (state, send) = React.useReducer(reducer, {courseCoaches, formVisible: None, saving: false})

  let closeFormCB = () => send(UpdateFormVisible(None))

  let updateCoachesCB = courseCoaches => {
    send(AddCourseCoaches(courseCoaches))
    send(UpdateFormVisible(None))
  }

  <DisablingCover containerClasses="min-h-full bg-gray-50 w-full" disabled=state.saving>
    <div key="School admin coaches course index" className="flex min-h-full bg-gray-50">
      {switch state.formVisible {
      | None => React.null
      | CoachEnrollmentForm =>
        <SchoolAdmin__EditorDrawer closeDrawerCB={_ => closeFormCB()}>
          <CourseCoaches__EnrollmentForm
            courseId schoolCoaches courseCoaches=state.courseCoaches updateCoachesCB
          />
        </SchoolAdmin__EditorDrawer>
      | CoachInfoForm(coach) =>
        <SchoolAdmin__EditorDrawer closeDrawerCB={_ => closeFormCB()}>
          <CourseCoaches__InfoForm courseId coach />
        </SchoolAdmin__EditorDrawer>
      }}
      <div className="flex-1 flex flex-col">
        {Array.length(schoolCoaches) == Array.length(state.courseCoaches) ||
          ArrayUtils.isEmpty(schoolCoaches)
          ? React.null
          : <div className="flex px-6 py-2 items-center justify-between">
              <button
                onClick={_event => {
                  ReactEvent.Mouse.preventDefault(_event)
                  send(UpdateFormVisible(CoachEnrollmentForm))
                }}
                className="max-w-2xl w-full flex mx-auto items-center justify-center relative bg-white text-primary-500 hover:text-primary-600 hover:shadow-lg focus:outline-none focus:border-primary-300 focus:bg-gray-50 focus:text-primary-600 focus:shadow-lg border-2 border-primary-300 border-dashed hover:border-primary-300 p-6 rounded-lg mt-8 cursor-pointer">
                <i className="fas fa-user-plus text-lg" />
                <h5 className="font-semibold ms-2"> {t("assign_coaches") |> str} </h5>
              </button>
            </div>}
        {state.courseCoaches |> ArrayUtils.isEmpty
          ? <div
              className="flex justify-center bg-gray-50 border rounded p-3 italic mx-auto max-w-2xl w-full mt-8">
              {t("course_empty") |> str}
            </div>
          : React.null}
        <div className="px-6 pb-4 mt-5 flex flex-1">
          <div className="max-w-2xl w-full mx-auto relative">
            <div className="flex mt-4 -mx-3 flex-wrap" ariaLabel={t("coaches_list")}>
              {state.courseCoaches->Belt.SortArray.stableSortBy((a, b) =>
                String.compare(a |> CourseCoach.name, b |> CourseCoach.name)
              )
              |> Array.map(coach =>
                <div key={coach |> CourseCoach.id} className="flex w-1/2 shrink-0 mb-5 px-3">
                  <div
                    id={coach |> CourseCoach.name}
                    className="shadow bg-white cursor-pointer rounded-lg flex w-full border border-transparent overflow-hidden hover:border-primary-400 hover:bg-gray-50 focus-within:outline-none focus-within:ring-2 focus-within:ring-focusColor-500">
                    <div className="flex flex-1 justify-between">
                      <button
                        ariaLabel={"View " ++ CourseCoach.name(coach)}
                        onClick={_ => send(UpdateFormVisible(CoachInfoForm(coach)))}
                        className="flex flex-1 py-4 px-4 items-center  focus:outline-none focus:bg-gray-50 focus:text-primary-500">
                        <span className="me-4 shrink-0">
                          {switch coach |> CourseCoach.avatarUrl {
                          | Some(avatarUrl) =>
                            <img className="w-10 h-10 rounded-full object-cover" src=avatarUrl />
                          | None =>
                            <Avatar
                              name={coach |> CourseCoach.name} className="w-10 h-10 rounded-full"
                            />
                          }}
                        </span>
                        <div className="text-sm">
                          <p className="text-black font-semibold mt-1">
                            {coach |> CourseCoach.name |> str}
                          </p>
                          <p className="text-gray-600 text-xs mt-px">
                            {coach |> CourseCoach.title |> str}
                          </p>
                        </div>
                      </button>
                      <button
                        className="w-10 text-sm course-faculty__list-item-remove text-gray-600 cursor-pointer flex items-center justify-center hover:text-red-500 hover:bg-gray-50 focus:outline-none focus:text-red-500 focus:bg-gray-50"
                        ariaLabel={ts("delete") ++ " " ++ (coach |> CourseCoach.name)}
                        onClick={removeCoach(send, courseId, authenticityToken, coach)}>
                        <i className="fas fa-trash-alt" />
                      </button>
                    </div>
                  </div>
                </div>
              )
              |> React.array}
            </div>
          </div>
        </div>
      </div>
    </div>
  </DisablingCover>
}
