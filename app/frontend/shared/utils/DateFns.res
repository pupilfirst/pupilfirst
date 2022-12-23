type locale

@deriving(abstract)
type formatDistanceOptions = {
  @optional
  includeSeconds: bool,
  @optional
  addSuffix: bool,
  @optional
  locale: locale,
}

@deriving(abstract)
type formatDistanceStrictOptions = {
  @optional
  addSuffix: bool,
  @optional
  unit: string,
  @optional
  roundingMethod: string,
  @optional
  locale: locale,
}

// TODO: This function should return the user's actual / selected timezone.
let currentTimeZone = () => "Asia/Kolkata"

// TODO: This function should return either "HH:mm", or "h:mm a" depending on user's preferred time format.
let selectedTimeFormat = () => "HH:mm"

@module("date-fns")
external formatDistanceOpt: (Js.Date.t, Js.Date.t, formatDistanceOptions) => string =
  "formatDistance"

@module("date-fns")
external formatDistanceStrictOpt: (Js.Date.t, Js.Date.t, formatDistanceStrictOptions) => string =
  "formatDistanceStrict"

@module("date-fns")
external formatDistanceToNowOpt: (Js.Date.t, formatDistanceOptions) => string =
  "formatDistanceToNow"

@module("date-fns")
external formatDistanceToNowStrictOpt: (Js.Date.t, formatDistanceStrictOptions) => string =
  "formatDistanceToNowStrict"

let formatDistance = (date, baseDate, ~includeSeconds=false, ~addSuffix=false, ()) => {
  let options = formatDistanceOptions(~includeSeconds, ~addSuffix, ())
  formatDistanceOpt(date, baseDate, options)
}

let formatDistanceStrict = (
  date,
  baseDate,
  ~addSuffix=false,
  ~unit=?,
  ~roundingMethod="round",
  (),
) => {
  let options = formatDistanceStrictOptions(~addSuffix, ~unit?, ~roundingMethod, ())
  formatDistanceStrictOpt(date, baseDate, options)
}

let formatDistanceToNow = (date, ~includeSeconds=false, ~addSuffix=false, ()) => {
  let options = formatDistanceOptions(~includeSeconds, ~addSuffix, ())
  formatDistanceToNowOpt(date, options)
}

let formatDistanceToNowStrict = (date, ~addSuffix=false, ~unit=?, ~roundingMethod="round", ()) => {
  let options = formatDistanceStrictOptions(~addSuffix, ~unit?, ~roundingMethod, ())

  formatDistanceToNowStrictOpt(date, options)
}

@deriving(abstract)
type formatOptions = {
  timeZone: string,
  @optional
  locale: locale,
  @optional
  weekStartsOn: int,
  @optional
  firstWeekContainsDate: int,
  @optional
  useAdditionalWeekYearTokens: bool,
  @optional
  useAdditionalDayOfYearTokens: bool,
}

@module("date-fns-tz")
external formatTz: (Js.Date.t, string, formatOptions) => string = "format"

let format = (date, fmt) => {
  let timeZone = currentTimeZone()

  // Since the passed date is not time-zone-sensitive, we need to pass the
  // time-zone here so that the user's timezone is displayed in the generated
  // string.
  formatTz(date, fmt, formatOptions(~timeZone, ()))
}

let formatPreset = (date, ~short=false, ~year=false, ~time=false, ()) => {
  let leading = short ? "MMM d" : "MMMM d"
  let middle = year ? ", yyyy" : ""
  let trailing = time ? " " ++ selectedTimeFormat() : ""

  format(date, leading ++ (middle ++ trailing))
}

@module("date-fns")
external decodeISOJs: Js.Json.t => Js.Date.t = "parseISO"

let decodeISO = json =>
  if Js.typeof(json) == "string" {
    decodeISOJs(json)
  } else {
    raise(Json.Decode.DecodeError("Expected string, got " ++ Js.typeof(json)))
  }

let encodeISO = date => Js.Date.toISOString(date)->Js.Json.string

@module("date-fns") external parseISO: string => Js.Date.t = "parseISO"

@module("date-fns") external isPast: Js.Date.t => bool = "isPast"

@module("date-fns") external isFuture: Js.Date.t => bool = "isFuture"

@module("date-fns")
external differenceInSeconds: (Js.Date.t, Js.Date.t) => int = "differenceInSeconds"

@module("date-fns")
external differenceInCalendarMonths : (Js.Date.t, Js.Date.t) => int = "differenceInCalendarMonths"

@module("date-fns")
external differenceInMinutes: (Js.Date.t, Js.Date.t) => int = "differenceInMinutes"

@module("date-fns")
external differenceInDays: (Js.Date.t, Js.Date.t) => int = "differenceInDays"

@module("date-fns")
external addDays: (Js.Date.t, int) => Js.Date.t = "addDays"

@module("date-fns")
external getDaysInMonth: Js.Date.t => float = "getDaysInMonth"
