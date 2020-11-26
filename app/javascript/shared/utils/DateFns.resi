type locale

let parseISO: string => Js.Date.t

let decodeISO: Js.Json.t => Js.Date.t

let encodeISO: Js.Date.t => Js.Json.t

let differenceInSeconds: (Js.Date.t, Js.Date.t) => int

let isPast: Js.Date.t => bool

let isFuture: Js.Date.t => bool

@ocaml.doc(
  "
 * `format(date, fmt)` returns the date as a string in the desired format, and in the user's timezone.
 *
 * See https://date-fns.org/v2.12.0/docs/format
 "
)
let format: (Js.Date.t, string) => string

@ocaml.doc(
  "
 * `formatPreset(date, ~short=false, ~year=false, ~time=false)` formats a given date to a few preset 'shapes':
 *
 * - `~short` controls the length of the month string. `~year` controls whether the year is shown, and `~time` controls whether the time is shown. For example:
 * - * `~short=false ~year=true ~time=true` can have format \"MMMM d, yyyy HH:mm\" or \"MMMM d, yyyy h:mm a\" depending on the user's preferred time format.
 * - `~short=true ~year=false ~time=false` will have format \"MMM d\"
 "
)
let formatPreset: (Js.Date.t, ~short: bool=?, ~year: bool=?, ~time: bool=?, unit) => string

let formatDistance: (
  Js.Date.t,
  Js.Date.t,
  ~includeSeconds: bool=?,
  ~addSuffix: bool=?,
  unit,
) => string

let formatDistanceStrict: (
  Js.Date.t,
  Js.Date.t,
  ~addSuffix: bool=?,
  ~unit: string=?,
  ~roundingMethod: string=?,
  unit,
) => string

let formatDistanceToNow: (Js.Date.t, ~includeSeconds: bool=?, ~addSuffix: bool=?, unit) => string

let formatDistanceToNowStrict: (
  Js.Date.t,
  ~addSuffix: bool=?,
  ~unit: string=?,
  ~roundingMethod: string=?,
  unit,
) => string
