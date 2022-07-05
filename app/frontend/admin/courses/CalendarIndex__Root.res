let str = React.string

// Calendar Creator ------------------------------------------------------------

// <School__PageHeader
//   exitUrl={`/school/courses/${courseId}/calendar`}
//   title="Add new calendar"
//   description={"{Course name}"}
// />
// <AdminCoursesShared__CalendarEditor />

// -----------------------------------------------------------------------------



let renderCalenderSelector = () => {
    <div className="flex items-center justify-between gap-2 px-1 rounded-md hover:bg-gray-100">
      // <Checkbox
      //   label="Show all events"
      //   checked={checked}
      //   onChange={}
      // />
      <p> {"calendar name"->str} </p>
      <button
        className="p-2 rounded-md hover:bg-primary-50 hover:text-primary-500 focus:bg-primary-50 focus:text-primary-500"
        // onClick={_ => {}}>
        ariaLabel="More"
        title="More">
        <PfIcon className="if i-kebab-regular if-fw" />
      </button>
    </div>
  }

  let noEventToday = () => {
    <div className="p-4 flex items-center justify-center gap-1 bg-gray-100 rounded-md">
      <PfIcon className="if i-calendar-regular if-fw" />
      <p> {"No event scheduled for today"->str} </p>
    </div>
  }


@react.component
let make = () => {
  <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4 mt-8">
    <div className="flex items-center justify-between gap-2">
      <h1 className="text-xl font-semibold"> {"Calendar"->str} </h1>
      <Link
        href="#"
        className="text-primary-500 font-medium text-sm hover:underline">
        {"See all upcoming events"->str}
      </Link>
    </div>
    <div
      className="flex border border-gray-200 rounded-lg text-sm mt-6 overflow-hidden">
      <div className="p-6 bg-gray-100 border-r border-gray-200 max-w-xs">
        // Replace with Calendar componenet
        <div className="h-64 w-64 bg-green-50" />
        // ---------
        <div className="mt-4 flex items-center justify-between gap-2 p-1">
          <p className="text-base font-medium "> {"Calendars"->str} </p>
          <button
            className="p-2 rounded-md hover:bg-primary-50 hover:text-primary-500 focus:bg-primary-50 focus:text-primary-500"
            ariaLabel="Add new calendar"
            title="Add new Calendar">
            <PfIcon className="if i-plus-regular if-fw" />
          </button>
        </div>
        <div> {renderCalenderSelector()} </div>
      </div>
      <div className="p-6 bg-white flex-1">
        <div className="flex items-center justify-between gap-2">
          <p className="text-base font-medium"> {"Events"->str} </p>
          <p className="text-gray-600"> {"{11-November-2022}"->str} </p>
        </div>
        <button
          className="bg-primary-50 text-primary-500 font-semibold flex items-center justify-center gap-1 rounded-md p-4 w-full mt-6 hover:bg-primary-100">
          <PfIcon className="if i-plus-circle-regular if-fw" />
          {"Add an event"->str}
        </button>
        <div className="flex flex-col gap-4 mt-6">
          {noEventToday()}
          <EventCard
            id="1"
            url="#"
            name="Event 1"
            date="11-November-2022"
            startTime="10:00"
            endTime="11:00"
            calendar="Calendar 1"
            eventUrl="https://www.google.com"
            eventTitle="Event 1"
          />
          <EventCard
            id="2"
            url="#"
            name="Event 1"
            date="11-November-2022"
            startTime="10:00"
            endTime="11:00"
            calendar="Calendar 1"
            eventUrl="https://www.google.com"
            color="green"
            description="# This is an H1 #
              ## This is an H2 ##
              ### This is an H3 ######"
          />
        </div>
      </div>
    </div>
  </div>
}
