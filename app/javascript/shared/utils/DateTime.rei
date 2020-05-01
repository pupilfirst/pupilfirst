type t = Js.Date.t;

type format =
  | OnlyDate
  | DateWithYearAndTime;

let format: (format, t) => string;

let randomId: unit => string;
