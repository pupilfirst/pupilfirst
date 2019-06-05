exception UnsafeUnwrapFailed;

let unwrapUnsafely = o =>
  switch (o) {
  | Some(v) => v
  | None => raise(UnsafeUnwrapFailed)
  };