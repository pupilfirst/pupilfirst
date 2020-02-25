exception UnsafeFindFailed(string);

let copyAndSort = (f, t) => {
  let cp = t |> Array.copy;
  cp |> Array.sort(f);
  cp;
};

let copyAndUnshift = (e, t) => {
  let copy = t |> Array.copy;
  copy |> Js.Array.unshift(e) |> ignore;
  copy;
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

let flatten = t => {
  t |> Array.to_list |> List.flatten |> Array.of_list;
};

let distinct = t => t |> Array.to_list |> ListUtils.distinct |> Array.of_list;

let sort_uniq = (f, t) =>
  t |> Array.to_list |> List.sort_uniq(f) |> Array.of_list;

let getOpt = (a, i) =>
  try(Some(a |> Array.get(i))) {
  | Not_found => None
  };
