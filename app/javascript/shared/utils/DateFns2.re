type locale;

// TODO: This function should return the user's actual / selected timezone.
let currentTimezone = () => "Asia/Kolkata";

[@bs.module "date-fns-tz"]
external utcToZonedTime: (Js.Date.t, string) => Js.Date.t = "utcToZonedTime";

[@bs.module "date-fns-2"]
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

[@bs.module "date-fns-2"]
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

let format = (date, fmt) =>
  formatTz(date, fmt, formatOptions(~timeZone=currentTimezone(), ()));

[@bs.module "date-fns-2"]
external parseJson: Js.Json.t => Js.Date.t = "parseJSON";

[@bs.module "date-fns-2"] external parse: string => Js.Date.t = "parseJSON";

[@bs.module "date-fns-2"]
external isBefore: (Js.Date.t, Js.Date.t) => bool = "isBefore";

[@bs.module "date-fns-2"]
external isAfter: (Js.Date.t, Js.Date.t) => bool = "isAfter";

let isPast = date => {
  let zonedTime = utcToZonedTime(date, currentTimezone());
  zonedTime->isAfter(Js.Date.make());
};

let isFuture = date => {
  let zonedTime = utcToZonedTime(date, currentTimezone());
  zonedTime->isBefore(Js.Date.make());
};

[@bs.module "date-fns"]
external differenceInSeconds: (Js.Date.t, Js.Date.t) => int =
  "differenceInSeconds";
