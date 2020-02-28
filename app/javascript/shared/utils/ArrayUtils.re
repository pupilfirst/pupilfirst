exception UnsafeFindFailed(string);

let copyAndSort = (f, t) => {
  let cp = t |> Array.copy;
  cp |> Array.sort(f);
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
    Notification.error(
      "An unexpected error occurred",
      "Our team has been notified about this error. Please try reloading this page.",
    );
    raise(UnsafeFindFailed(message));
  };

let flatten = t => {
  t |> Array.to_list |> List.flatten |> Array.of_list;
};

let distinct = t => t |> Array.to_list |> ListUtils.distinct |> Array.of_list;

let sort_uniq = (f, t) =>
  t |> Array.to_list |> List.sort_uniq(f) |> Array.of_list;
