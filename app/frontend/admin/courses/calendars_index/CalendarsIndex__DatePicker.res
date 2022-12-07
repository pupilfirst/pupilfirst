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
      dayEventsLoadStatus: Loading,
      selectedMonthDeviation: state.selectedMonthDeviation + 1,
    }
  | ChangeToPreviousMonth => {
      ...state,
      dayEventsLoadStatus: Loading,
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

let daysOfMonth = (selectedMonth, selectedDate, dayStatuses) => {
  let daysInMonth = selectedMonth |> DateFns.getDaysInMonth |> int_of_float
  let daysAsArray = Array.make(daysInMonth, 1) |> Js.Array.mapi((day, index) => day + index)
  let currentMonthAsString = selectedMonth->DateFns.format("yyyy-mm-")
  let selectedDateAsString = selectedDate->DateFns.format("yyyy-mm-dd")
  daysAsArray
  |> Js.Array.map(day => {
    let dayAsString =
      currentMonthAsString ++ (day < 10 ? "0" ++ string_of_int(day) : string_of_int(day))
    <button
      key=dayAsString
      onClick={_ => Js.log("mahesh")}
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
let make = (~test) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      selectedDate: Js.Date.make(),
      dayEventsLoadStatus: Loaded([]),
      selectedMonthDeviation: 0,
    },
  )

  let selectedMonth = computeSelectedMonth(state)
  let selectedDate = Js.Date.make()

  <div className="sticky top-0 bg-white border-r z-50 p-2 lg:p-0">
    <section className="px-2 py-2 lg:py-4">
      <div className="courses-calendar__container 2xl:px-3">
        <div className="flex justify-between lg:pt-4">
          <div className="courses-calendar__month-indicator flex items-center">
            <span
              className="flex justify-center items-center cursor-pointer h-7 w-7 p-1 text-sm bg-gray-300 text-gray-600 rounded-full hover:bg-gray-400 hover:text-gray-900">
              <i className="fas fa-chevron-left" />
            </span>
            <time className="px-2 md:px-4 text-sm xl:text-base" dateTime="2020-06">
              {selectedMonth->DateFns.format("mmm yyyy") |> str}
            </time>
            <span
              className="flex justify-center items-center cursor-pointer h-7 w-7 p-1 text-sm bg-gray-300 text-gray-600 rounded-full hover:bg-gray-400 hover:text-gray-900">
              <i className="fas fa-chevron-right" />
            </span>
          </div>
          <button className="px-2 py-1 text-sm bg-gray-200 rounded">
            <span> {"Today" |> str} </span>
          </button>
        </div>
        <div className="courses-calendar__day-of-week">
          <div> {"Su" |> str} </div>
          <div> {"Mo" |> str} </div>
          <div> {"Tu" |> str} </div>
          <div> {"We" |> str} </div>
          <div> {"Th" |> str} </div>
          <div> {"Fr" |> str} </div>
          <div> {"Sa" |> str} </div>
        </div>
        <div>
          {switch state.dayEventsLoadStatus {
          | Loading => SkeletonLoading.paragraph()
          | Loaded(statuses) =>
            <div
              className={"courses-calendar__date-grid courses-calendar__date-grid--start-on-" ++
              startOnDayClass(selectedMonth)}>
              {daysOfMonth(selectedMonth, selectedDate, statuses)}
            </div>
          }}
        </div>
      </div>
    </section>
  </div>
}

let makeFromJson = _props => {
  make({"test": "test"})
}
