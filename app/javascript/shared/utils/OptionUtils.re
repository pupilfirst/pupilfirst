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
