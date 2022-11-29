let str = React.string

@react.component
let make = (~courseId) => {
  <DisablingCover disabled={false}>
    <div className="max-w-5xl mx-auto">
      <div className="max-w-5xl mx-auto px-2">
        <div className="mt-8">
          <label className="block text-sm font-semibold mb-2" htmlFor="calendarName">
            {"Calendar name"->str}
          </label>
          <input
          // value={}
          // onChange={event => }
            className="appearance-none block w-full text-sm bg-white border border-gray-300 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:ring-2 focus:ring-focusColor-500"
            id="calendarName"
            type_="text"
            placeholder="eg, Batch 1"
          />
          <School__InputGroupError message="" active={false} />
        </div>
        <div className="mt-6">
          <label className="block text-sm font-semibold mb-2" htmlFor="linkCalendar">
            {"Link calendar to" |> str}
          </label>
          // <MultiselectDropdown />
          <School__InputGroupError message="" active={false} />
        </div>
        {<button className="btn btn-primary btn-large w-full mt-6" type_="submit" disabled={false}>
          {"Add calendar"->str}
        </button>}
      </div>
    </div>
  </DisablingCover>
}
