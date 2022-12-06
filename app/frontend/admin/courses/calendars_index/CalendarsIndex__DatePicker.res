exception WeekDayInvalid(string)
let str = React.string

type calendarDayStatus = { }

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

let daysOfMonth = (selectedMonth, selectedDate, selectDateCB, dayStatuses) => {
  let daysInMonth = selectedMonth |> DateFns.getDaysInMonth |> int_of_float
  let daysAsArray = Array.make(daysInMonth, 1) |> Js.Array.mapi((day, index) => day + index)
  let currentMonthAsString = selectedMonth |> DateFns.format("YYYY-MM-")
  let selectedDateAsString = selectedDate |> DateFns.format("YYYY-MM-DD")
  daysAsArray
  |> Js.Array.map(day => {
    let dayAsString =
      currentMonthAsString ++ (day < 10 ? "0" ++ string_of_int(day) : string_of_int(day))
    <button
      key=dayAsString
      onClick={_ => selectDateCB(dayAsString |> Js.Date.fromString)}
      className={"bookings-calendar__date-grid-button " ++ (
        selectedDateAsString == dayAsString
          ? "bookings-calendar__date-grid-button--is-selected"
          : ""
      )}>
      <time dateTime=dayAsString> {day |> string_of_int |> str} </time>
      {
        let available = computeStatus(day, MonthStatus.availableDays(dayStatuses))
        let confirmed = computeStatus(day, MonthStatus.confirmedDays(dayStatuses))
        let unconfirmed = computeStatus(day, MonthStatus.unconfirmedDays(dayStatuses))

        selectedDateAsString == dayAsString
          ? React.null
          : <div className="bookings-calendar__booking-status-container space-x-1">
              {available
                ? <span
                    className="bookings-calendar__booking-status bookings-calendar__booking-status--available"
                  />
                : React.null}
              {confirmed
                ? <span
                    className="bookings-calendar__booking-status bookings-calendar__booking-status--booked"
                  />
                : React.null}
              {unconfirmed
                ? <span
                    className="bookings-calendar__booking-status bookings-calendar__booking-status--unconfirmed"
                  />
                : React.null}
            </div>
      }
    </button>
  })
  |> React.array
}

@react.component
let make = (
  ~selectedMonth,
  ~selectedDate,
  ~dayStatuses,
  ~nextMonthCB,
  ~prevMonthCB,
  ~selectTodayCB,
  ~selectDateCB,
  ~toggleCalendarCB,
) =>
  <div className="lg:w-4/12 sticky top-0 bg-white border-r z-50 p-2 lg:p-0">
    <div className="p-2 hidden lg:block">
      <span
        onClick={_ => toggleCalendarCB()}
        className="flex justify-center items-center cursor-pointer h-7 w-7 p-2 text-sm bg-blue-400 text-white rounded-full hover:bg-gray-400 hover:text-gray-900">
        <i className="fas fa-chevron-left" />
      </span>
    </div>
    <section className="px-2 py-2 lg:py-4">
      <div className="bookings-calendar__container 2xl:px-3">
        <div className="flex justify-between lg:pt-4">
          <div className="bookings-calendar__month-indicator flex items-center">
            <span
              onClick={_ => prevMonthCB()}
              className="flex justify-center items-center cursor-pointer h-7 w-7 p-1 text-sm bg-gray-300 text-gray-600 rounded-full hover:bg-gray-400 hover:text-gray-900">
              <i className="fas fa-chevron-left" />
            </span>
            <time className="px-2 md:px-4 text-sm xl:text-base" dateTime="2020-06">
              {selectedMonth |> DateFns.format("MMM YYYY") |> str}
            </time>
            <span
              onClick={_ => nextMonthCB()}
              className="flex justify-center items-center cursor-pointer h-7 w-7 p-1 text-sm bg-gray-300 text-gray-600 rounded-full hover:bg-gray-400 hover:text-gray-900">
              <i className="fas fa-chevron-right" />
            </span>
          </div>
          <button onClick={_ => selectTodayCB()} className="px-2 py-1 text-sm bg-gray-200 rounded">
            <span> {"Today" |> str} </span>
          </button>
        </div>
        <div className="bookings-calendar__day-of-week">
          <div> {"Su" |> str} </div>
          <div> {"Mo" |> str} </div>
          <div> {"Tu" |> str} </div>
          <div> {"We" |> str} </div>
          <div> {"Th" |> str} </div>
          <div> {"Fr" |> str} </div>
          <div> {"Sa" |> str} </div>
        </div>
        <div>
          {switch dayStatuses {
          | Bookings__MonthStatuses.Loading => SkeletonLoading.calendar()
          | Loaded(statuses) =>
            <div
              className={"bookings-calendar__date-grid bookings-calendar__date-grid--start-on-" ++
              startOnDayClass(selectedMonth)}>
              {daysOfMonth(selectedMonth, selectedDate, selectDateCB, statuses)}
            </div>
          }}
        </div>
      </div>
      <div
        className="flex flex-col xl:flex-row justify-start xl:justify-center border-t xl:space-x-8 text-xs mt-4 py-2 xl:py-4">
        <div className="flex items-center">
          <span className="w-2 h-2 bg-green-500 rounded-full" />
          <span className="pl-1"> {"Available" |> str} </span>
        </div>
        <div className="flex items-center">
          <span className="w-2 h-2 bg-red-500 rounded-full" />
          <span className="pl-1"> {"Booked" |> str} </span>
        </div>
        <div className="flex items-center">
          <span className="w-2 h-2 bg-yellow-500 rounded-full" />
          <span className="pl-1"> {"Unconfirmed" |> str} </span>
        </div>
      </div>
    </section>
  </div>
