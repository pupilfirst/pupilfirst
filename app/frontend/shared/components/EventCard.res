let str = React.string

@react.component
let make = (
  ~id,
  ~url,
  ~name,
  ~date,
  ~startTime,
  ~endTime,
  ~calendar,
  ~eventUrl=?,
  ~eventTitle=?,
  ~color="yellow",
  ~description=?,
) => {
  <div key={id} className={`px-4 bg-${color}-50 rounded-md`}>
    <Link href={url} className="hover:underline focus:underline">
      <div className="py-4 flex justify-between border-b border-gray-200">
        <div className="flex gap-3 items-center">
          <div className={`w-3 h-3 bg-${color}-500 rounded`} />
          <div>
            <p className="font-semibold text-base"> {name->str} </p>
            <p className="font-medium">
              {(date ++ ",  " ++ startTime ++ "  -  " ++ endTime)->str}
            </p>
          </div>
        </div>
        <p className="text-gray-600"> {calendar->str} </p>
      </div>
    </Link>
    {switch eventUrl {
    | Some(eventUrl) =>
      <a
        href={eventUrl}
        target="_blank"
        className="text-primary-500 font-medium hover:underline focus:underline">
        <div className="py-4 flex gap-2 items-center">
          <PfIcon className="if i-external-link-regular if-fw rtl:-rotate-90" />
          <p>
            {switch eventTitle {
            | Some(eventTitle) => eventTitle
            | None => "Join event"
            }->str}
          </p>
        </div>
      </a>
    | None => React.null
    }}
    {switch description {
    | Some(description) =>
      <div className="py-4 border-t border-gray-200">
        <MarkdownBlock
          markdown={description} className="overflow-auto w-full" profile=Markdown.Permissive
        />
      </div>
    | None => React.null
    }}
  </div>
}
