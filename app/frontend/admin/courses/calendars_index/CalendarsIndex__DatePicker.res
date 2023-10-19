%%raw(`import "./CalendarsIndex__DatePicker.css"`)
open Json.Decode
exception InvalidSource(string)
exception WeekDayInvalid(string)
let str = React.string

let t = I18n.t(~scope="components.CalendarsIndex__DatePicker")

let computeStatus = (day, daysWithStatus) => daysWithStatus |> Array.mem(day)

let startOnDayClass = currentMonth => {
  let day = currentMonth |> Js.Date.getDay |> int_of_float

  switch day {
  | 0 => "sun"
  | 1 => "mon"
  | 2 => "tue"
  | 3 => "wed"
  | 4 => "thu"
  | 5 => "fri"
  | 6 => "sat"
  | _ => raise(WeekDayInvalid("Not a valid weekday"))
  }
}

type dayEventsLoadStatus = Loading | Loaded(Js.Json.t)

type state = {
  selectedDate: Js.Date.t,
  selectedMonthDeviation: int,
  dayEventsLoadStatus: dayEventsLoadStatus,
}

type action =
  | ChangeToNextMonth
  | ChangeToPreviousMonth
  | ChangeDate(Js.Date.t)
  | ChangeDateToToday
  | StartLoadingStatus
  | FinishLoadingStatus(Js.Json.t)

let computeSelectedMonth = state => {
  let currentDate = Js.Date.make()
  let month = currentDate->Js.Date.getMonth +. float_of_int(state.selectedMonthDeviation)
  let year = currentDate->Js.Date.getFullYear
  Js.Date.makeWithYM(~year, ~month, ())
}

let reducer = (state, action) => {
  switch action {
  | ChangeToNextMonth => {
      ...state,
      dayEventsLoadStatus: Loading,
      selectedMonthDeviation: state.selectedMonthDeviation + 1,
    }
  | ChangeToPreviousMonth => {
      ...state,
      dayEventsLoadStatus: Loading,
      selectedMonthDeviation: state.selectedMonthDeviation - 1,
    }
  | ChangeDate(selectedDate) => {...state, selectedDate}
  | ChangeDateToToday => {
      ...state,
      selectedDate: Js.Date.make(),
      selectedMonthDeviation: 0,
    }
  | StartLoadingStatus => {...state, dayEventsLoadStatus: Loading}
  | FinishLoadingStatus(statuses) => {
      ...state,
      dayEventsLoadStatus: Loaded(statuses),
    }
  }
}

let decodeJsonAsStringArray = (. x) => {
  Json.Decode.array(string)(x)
}

let reloadPage = selectedDate => {
  let search = Webapi.Dom.location->Webapi.Dom.Location.search
  let params = Webapi.Url.URLSearchParams.make(search)
  Webapi.Url.URLSearchParams.set(params, "date", selectedDate)
  let currentPath = Webapi.Dom.location->Webapi.Dom.Location.pathname
  let searchString = Webapi.Url.URLSearchParams.toString(params)
  Webapi.Dom.window->Webapi.Dom.Window.setLocation(`${currentPath}?${searchString}`)
}

let daysOfMonth = (selectedMonth, selectedDate, dayStatuses) => {
  let daysInMonth = selectedMonth->DateFns.getDaysInMonth->int_of_float
  let daysAsArray = Array.make(daysInMonth, 1)->Js.Array2.mapi((day, index) => day + index)
  let currentMonthAsString = selectedMonth->DateFns.format("yyyy-MM-")
  let selectedDateAsString = selectedDate->DateFns.format("yyyy-MM-dd")
  let parsedStatuses =
    Js.Json.decodeObject(dayStatuses)->Belt.Option.getWithDefault(Js.Dict.empty())
      |> Js.Dict.map(decodeJsonAsStringArray)

  daysAsArray
  ->Js.Array2.map(day => {
    let dayAsString =
      currentMonthAsString ++ (day < 10 ? "0" ++ string_of_int(day) : string_of_int(day))
    <button
      key=dayAsString
      onClick={_ => reloadPage(dayAsString)}
      className={"courses-calendar__date-grid-button flex flex-col items-center justify-center pt-3 " ++ (
        selectedDateAsString == dayAsString
          ? "courses-calendar__date-grid-button--is-selected"
          : "hover:text-primary-500 hover:bg-primary-100 focus:bg-primary-100 focus:ring-2 focus:ring-focusColor-500 transition"
      )}>
      <div className="flex justify-center">
        <time dateTime=dayAsString> {day->string_of_int->str} </time>
      </div>
      <div className="h-3 flex items-center">
        {
          let dayStatus = parsedStatuses->Js.Dict.get(dayAsString)->Belt.Option.getWithDefault([])

          selectedDateAsString == dayAsString || dayStatus->ArrayUtils.isEmpty
            ? React.null
            : <div className="flex gap-0.5">
                {dayStatus
                ->Js.Array2.map(color => {
                  <div className={`h-1.5 w-1.5 bg-${color}-500 rounded-full`} />
                })
                ->React.array}
              </div>
        }
      </div>
    </button>
  })
  ->React.array
}

let getMonthEventStatus = (selectedMonth, source, selectedCalendarId, courseId, send) => {
  send(StartLoadingStatus)
  let monthStartAsString = selectedMonth->DateFns.format("yyyy-MM") ++ "-01"

  let path = switch source {
  | "student" => "/courses/"
  | "admin" => "/school/courses/"
  | _ => raise(InvalidSource("Invalid source"))
  }

  let url =
    path ++
    courseId ++
    "/calendar_month_data" ++
    "?date=" ++
    monthStartAsString ++
    switch selectedCalendarId {
    | Some(id) => "&calendar_id=" ++ id
    | None => ""
    }
  Api.get(
    ~url,
    ~responseCB=res => send(FinishLoadingStatus(res)),
    ~errorCB=() => send(FinishLoadingStatus(Js.Json.null)),
    ~notify=false,
  )
}

@react.component
let make = (~selectedDate, ~source, ~selectedCalendarId=?, ~courseId) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      selectedDate: DateFns.parseISO(selectedDate),
      dayEventsLoadStatus: Loading,
      selectedMonthDeviation: DateFns.differenceInCalendarMonths(
        DateFns.parseISO(selectedDate),
        Js.Date.make(),
      ),
    },
  )

  let selectedMonth = computeSelectedMonth(state)

  React.useEffect1(() => {
    getMonthEventStatus(selectedMonth, source, selectedCalendarId, courseId, send)
    None
  }, [state.selectedMonthDeviation])

  <div className="sticky top-0 z-50">
    <section>
      <div className="courses-calendar__container 2xl:px-3">
        <div className="flex justify-between">
          <div className="courses-calendar__month-indicator flex items-center">
            <button
              onClick={_ => send(ChangeToPreviousMonth)}
              className="flex justify-center items-center cursor-pointer h-7 w-7 p-1 text-sm bg-gray-100 border border-gray-200 text-gray-500 rounded-md hover:text-primary-500 hover:bg-primary-100 focus:ring-2 focus:ring-focusColor-500 transition">
              <i className="fas fa-chevron-left rtl:rotate-180 me-px" />
            </button>
            <time className="px-2 md:px-4 text-sm xl:text-base" dateTime="2020-06">
              {selectedMonth->DateFns.format("MMM yyyy")->str}
            </time>
            <button
              onClick={_ => send(ChangeToNextMonth)}
              className="flex justify-center items-center cursor-pointer h-7 w-7 p-1 text-sm bg-gray-100 border border-gray-200 text-gray-500 rounded-md hover:text-primary-500 hover:bg-primary-100 focus:ring-2 focus:ring-focusColor-500 transition">
              <i className="fas fa-chevron-right rtl:rotate-180 ms-px" />
            </button>
          </div>
          <button
            onClick={_ => reloadPage(Js.Date.make()->DateFns.format("yyyy-MM-dd"))}
            className="px-2 py-1 text-sm bg-gray-100 font-medium border rounded-md hover:text-primary-500 hover:bg-primary-100 focus:ring-2 focus:ring-focusColor-500 transition">
            <span> {t("today")->str} </span>
          </button>
        </div>
        <div className="courses-calendar__day-of-week">
          <div> {"Su"->str} </div>
          <div> {"Mo"->str} </div>
          <div> {"Tu"->str} </div>
          <div> {"We"->str} </div>
          <div> {"Th"->str} </div>
          <div> {"Fr"->str} </div>
          <div> {"Sa"->str} </div>
        </div>
        <div>
          {switch state.dayEventsLoadStatus {
          | Loading => SkeletonLoading.calendar()
          | Loaded(statuses) =>
            <div
              className={"courses-calendar__date-grid courses-calendar__date-grid--start-on-" ++
              startOnDayClass(selectedMonth)}>
              {daysOfMonth(selectedMonth, state.selectedDate, statuses)}
            </div>
          }}
        </div>
      </div>
    </section>
  </div>
}

let makeFromJson = json => {
  make({
    "selectedDate": field("selectedDate", string, json),
    "selectedCalendarId": optional(field("selectedCalendarId", string), json),
    "courseId": field("courseId", string, json),
    "source": field("source", string, json),
  })
}
