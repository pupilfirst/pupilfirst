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
