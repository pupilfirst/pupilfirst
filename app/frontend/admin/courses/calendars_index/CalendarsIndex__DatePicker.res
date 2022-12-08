%%raw(`import "./CalendarsIndex__DatePicker.css"`)

exception WeekDayInvalid(string)
let str = React.string

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

type dayEventsLoadStatus = Loading | Loaded(array<array<string>>)

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
  | FinishLoadingStatus(array<array<string>>)

let computeSelectedMonth = state => {
  let currentDate = Js.Date.make()
  let month = (currentDate |> Js.Date.getMonth) +. float_of_int(state.selectedMonthDeviation)
  let year = currentDate |> Js.Date.getFullYear
  Js.Date.makeWithYM(~year, ~month, ())
}

let reducer = (state, action) => {
  switch action {
  | ChangeToNextMonth => {
      ...state,
      dayEventsLoadStatus: Loaded([]),
      selectedMonthDeviation: state.selectedMonthDeviation + 1,
    }
  | ChangeToPreviousMonth => {
      ...state,
      dayEventsLoadStatus: Loaded([]),
      selectedMonthDeviation: state.selectedMonthDeviation - 1,
    }
  | ChangeDate(selectedDate) => {...state, selectedDate: selectedDate}
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

let daysOfMonth = (selectedMonth, selectedDate, dayStatuses, send) => {
  let daysInMonth = selectedMonth |> DateFns.getDaysInMonth |> int_of_float
  let daysAsArray = Array.make(daysInMonth, 1) |> Js.Array.mapi((day, index) => day + index)
  let currentMonthAsString = selectedMonth->DateFns.format("yyyy-MM-")
  let selectedDateAsString = selectedDate->DateFns.format("yyyy-MM-dd")
  daysAsArray
  |> Js.Array.map(day => {
    let dayAsString =
      currentMonthAsString ++ (day < 10 ? "0" ++ string_of_int(day) : string_of_int(day))
    <button
      key=dayAsString
      onClick={_ => send(ChangeDate(DateFns.parseISO(dayAsString)))}
      className={"courses-calendar__date-grid-button " ++ (
        selectedDateAsString == dayAsString ? "courses-calendar__date-grid-button--is-selected" : ""
      )}>
      <time dateTime=dayAsString> {day |> string_of_int |> str} </time>
      {
        let available = true
        let confirmed = false
        let unconfirmed = true

        selectedDateAsString == dayAsString
          ? React.null
          : <div className="courses-calendar__booking-status-container space-x-1">
              {available
                ? <span
                    className="courses-calendar__booking-status courses-calendar__booking-status--available"
                  />
                : React.null}
              {confirmed
                ? <span
                    className="courses-calendar__booking-status courses-calendar__booking-status--booked"
                  />
                : React.null}
              {unconfirmed
                ? <span
                    className="courses-calendar__booking-status courses-calendar__booking-status--unconfirmed"
                  />
                : React.null}
            </div>
      }
    </button>
  })
  |> React.array
}

@react.component
let make = (~selectedDate) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      selectedDate: switch selectedDate {
      | Some(date) => DateFns.parseISO(date)
      | None => Js.Date.make()
      },
      dayEventsLoadStatus: Loaded([]),
      selectedMonthDeviation: 0,
    },
  )

  let selectedMonth = computeSelectedMonth(state)

  <div className="sticky top-0 z-50 p-2 lg:p-0">
    <section>
      <div className="courses-calendar__container 2xl:px-3">
        <div className="flex justify-between">
          <div className="courses-calendar__month-indicator flex items-center">
            <button
              onClick={_ => send(ChangeToPreviousMonth)}
              className="flex justify-center items-center cursor-pointer h-7 w-7 p-1 text-sm bg-gray-100 border border-gray-200 text-gray-500 rounded-full hover:text-primary-500 focus:bg-primary-50 focus:text-primary-500">
              <i className="fas fa-chevron-left" />
            </button>
            <time className="px-2 md:px-4 text-sm xl:text-base" dateTime="2020-06">
              {selectedMonth->DateFns.format("MMM yyyy")->str}
            </time>
            <button
              onClick={_ => send(ChangeToNextMonth)}
              className="flex justify-center items-center cursor-pointer h-7 w-7 p-1 text-sm bg-gray-100 border border-gray-200 text-gray-500 rounded-full hover:text-primary-500 focus:bg-primary-50 focus:text-primary-500">
              <i className="fas fa-chevron-right" />
            </button>
          </div>
          <button
            className="px-2 py-1 text-sm bg-gray-100 rounded hover:bg-primary-50 hover:text-primary-500 focus:bg-primary-50 focus:text-primary-500">
            <span> {"Today"->str} </span>
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
          | Loading => SkeletonLoading.paragraph()
          | Loaded(statuses) =>
            <div
              className={"courses-calendar__date-grid courses-calendar__date-grid--start-on-" ++
              startOnDayClass(selectedMonth)}>
              {daysOfMonth(selectedMonth, state.selectedDate, statuses, send)}
            </div>
          }}
        </div>
      </div>
    </section>
  </div>
}

let makeFromJson = _props => {
  make({"selectedDate": Some("2022-12-07")})
}
