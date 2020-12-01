type locale

@bs.deriving(abstract)
type formatDistanceOptions = {
  @bs.optional
  includeSeconds: bool,
  @bs.optional
  addSuffix: bool,
  @bs.optional
  locale: locale,
}

@bs.deriving(abstract)
type formatDistanceStrictOptions = {
  @bs.optional
  addSuffix: bool,
  @bs.optional
  unit: string,
  @bs.optional
  roundingMethod: string,
  @bs.optional
  locale: locale,
}

// TODO: This function should return the user's actual / selected timezone.
let currentTimeZone = () => "Asia/Kolkata"

// TODO: This function should return either "HH:mm", or "h:mm a" depending on user's preferred time format.
let selectedTimeFormat = () => "HH:mm"

@bs.module("date-fns")
external formatDistanceOpt: (Js.Date.t, Js.Date.t, formatDistanceOptions) => string =
  "formatDistance"

@bs.module("date-fns")
external formatDistanceStrictOpt: (Js.Date.t, Js.Date.t, formatDistanceStrictOptions) => string =
  "formatDistanceStrict"

@bs.module("date-fns")
external formatDistanceToNowOpt: (Js.Date.t, formatDistanceOptions) => string =
  "formatDistanceToNow"

@bs.module("date-fns")
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

@bs.deriving(abstract)
type formatOptions = {
  timeZone: string,
  @bs.optional
  locale: locale,
  @bs.optional
  weekStartsOn: int,
  @bs.optional
  firstWeekContainsDate: int,
  @bs.optional
  useAdditionalWeekYearTokens: bool,
  @bs.optional
  useAdditionalDayOfYearTokens: bool,
}

@bs.module("date-fns-tz")
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

@bs.module("date-fns")
external decodeISOJs: Js.Json.t => Js.Date.t = "parseISO"

let decodeISO = json =>
  if Js.typeof(json) == "string" {
    decodeISOJs(json)
  } else {
    raise(Json.Decode.DecodeError("Expected string, got " ++ Js.typeof(json)))
  }

let encodeISO = date => Js.Date.toISOString(date)->Js.Json.string

@bs.module("date-fns") external parseISO: string => Js.Date.t = "parseISO"

@bs.module("date-fns") external isPast: Js.Date.t => bool = "isPast"

@bs.module("date-fns") external isFuture: Js.Date.t => bool = "isFuture"

@bs.module("date-fns")
external differenceInSeconds: (Js.Date.t, Js.Date.t) => int = "differenceInSeconds"
