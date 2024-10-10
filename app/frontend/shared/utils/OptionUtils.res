let default = (e, v) =>
  switch v {
  | Some(v) => v
  | None => e
  }

// TODO: Remove all use of toString. Use `default("")` instead.
let toString = option => default("", option)

let map = (f, v) =>
  switch v {
  | Some(v) => Some(f(v))
  | None => None
  }

let flatMap = (f, v) => default(None, map(f, v))

let mapWithDefault = (f, d, v) => default(d, map(f, v))

let flat = t => t->Option.flatMap(x => x)
