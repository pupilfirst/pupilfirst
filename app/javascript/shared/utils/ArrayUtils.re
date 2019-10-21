exception UnsafeFindFailed(string);

let copyAndSort = (f, t) => {
  let cp = t |> Array.copy;
  cp |> Array.sort(f);
  cp;
};

let unsafeReplace = (item, index, t) => {
  let cp = t |> Array.copy;
  item |> Array.set(cp, index);
  cp;
};

let isEmpty = a =>
  switch (a) {
  | [||] => true
  | _ => false
  };

let isNotEmpty = a => !(a |> isEmpty);

let unsafeFind = (p, message, l) =>
  switch (Js.Array.find(p, l)) {
  | Some(e) => e
  | None =>
    Rollbar.error(message);
    raise(UnsafeFindFailed(message));
  };
