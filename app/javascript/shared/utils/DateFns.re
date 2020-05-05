type locale;

// TODO: This function should return the user's actual / selected timezone.
let currentTimezone = () => "Asia/Kolkata";

// TODO: This function should return either "HH:mm", or "h:mm a" depending on user's preferred time format.
let selectedTimeFormat = () => "HH:mm";

[@bs.module "date-fns-tz"]
external utcToZonedTime: (Js.Date.t, string) => Js.Date.t = "utcToZonedTime";

[@bs.module "date-fns-tz"]
external zonedTimeToUtcJs: (Js.Date.t, string) => Js.Date.t = "zonedTimeToUtc";

let zonedTimeToUtc = date => zonedTimeToUtcJs(date, currentTimezone());

[@bs.module "date-fns"]
external formatDistance: (Js.Date.t, Js.Date.t) => string = "formatDistance";

[@bs.deriving abstract]
type formatDistanceOptions = {
  [@bs.optional]
  includeSeconds: bool,
  [@bs.optional]
  addSuffix: bool,
  [@bs.optional]
  locale,
};

[@bs.module "date-fns"]
external formatDistanceOpt:
  (Js.Date.t, Js.Date.t, formatDistanceOptions) => string =
  "formatDistance";

let formatDistanceToNowOpt = (date, options) => {
  let zonedTime = utcToZonedTime(date, currentTimezone());
  zonedTime->formatDistanceOpt(Js.Date.make(), options);
};

[@bs.module "date-fns"]
external formatDistanceStrict: (Js.Date.t, Js.Date.t) => string =
  "formatDistanceStrict";

[@bs.deriving abstract]
type formatDistanceStrictOptions = {
  [@bs.optional]
  addSuffix: bool,
  [@bs.optional]
  unit: string,
  [@bs.optional]
  roundingMethod: string,
  [@bs.optional]
  locale,
};

[@bs.module "date-fns"]
external formatDistanceStrictOpt:
  (Js.Date.t, Js.Date.t, formatDistanceStrictOptions) => string =
  "formatDistanceStrict";

let formatDistanceToNowStrictOpt = (date, options) => {
  let zonedTime = utcToZonedTime(date, currentTimezone());
  zonedTime->formatDistanceStrictOpt(Js.Date.make(), options);
};

[@bs.deriving abstract]
type formatOptions = {
  timeZone: string,
  [@bs.optional]
  locale,
  [@bs.optional]
  weekStartsOn: int,
  [@bs.optional]
  firstWeekContainsDate: int,
  [@bs.optional]
  useAdditionalWeekYearTokens: bool,
  [@bs.optional]
  useAdditionalDayOfYearTokens: bool,
};

[@bs.module "date-fns-tz"]
external formatTz: (Js.Date.t, string, formatOptions) => string = "format";

let format = (date, fmt) => {
  let timeZone = currentTimezone();

  // Since the passed date is not time-zone-sensitive, we need to pass the
  // time-zone here so that the user's timezone is displayed in the generated
  // string.
  formatTz(date, fmt, formatOptions(~timeZone, ()));
};

let formatPreset = (date, ~short=false, ~year=false, ~time=false, ()) => {
  let leading = short ? "MMM d" : "MMMM d";
  let middle = year ? ", yyyy" : "";
  let trailing = time ? " " ++ selectedTimeFormat() : "";

  format(date, leading ++ middle ++ trailing);
};

[@bs.module "date-fns"]
external decodeISO: Js.Json.t => Js.Date.t = "parseISO";

[@bs.module "date-fns"] external parseISO: string => Js.Date.t = "parseISO";

[@bs.module "date-fns"] external isPast: Js.Date.t => bool = "isPast";

[@bs.module "date-fns"] external isFuture: Js.Date.t => bool = "isFuture";

[@bs.module "date-fns"]
external differenceInSeconds: (Js.Date.t, Js.Date.t) => int =
  "differenceInSeconds";
