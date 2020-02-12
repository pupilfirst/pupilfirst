type t;

type format =
  | OnlyDate
  | DateWithYearAndTime;

let parse: string => t;

let format: (format, t) => string;

let stingToFormatedTime: (format, string) => string;

let randomId: unit => string;
