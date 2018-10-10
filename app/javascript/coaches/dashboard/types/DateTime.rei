type t;

type format =
  | OnlyDate
  | DateAndTime;

let parse: string => t;

let format: (format, t) => string;