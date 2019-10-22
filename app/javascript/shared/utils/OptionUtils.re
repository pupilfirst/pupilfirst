exception UnsafeUnwrapFailed;

let unwrapUnsafely = o =>
  switch (o) {
  | Some(v) => v
  | None => raise(UnsafeUnwrapFailed)
  };

let toString = option =>
  switch (option) {
  | Some(v) => v
  | None => ""
  };

let map = (f, v) =>
  switch (v) {
  | Some(v) => Some(f(v))
  | None => None
  };
