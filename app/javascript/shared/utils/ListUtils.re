exception UnsafeFindFailed(string);

let isEmpty = l =>
  switch (l) {
  | [_h, ..._t] => false
  | [] => true
  };

let isNotEmpty = l => !(l |> isEmpty);

let findOpt = (p, l) =>
  try (Some(List.find(p, l))) {
  | Not_found => None
  };

let unsafeFind = (p, message, l) =>
  try (List.find(p, l)) {
  | Not_found =>
    Rollbar.error(message);
    raise(UnsafeFindFailed(message));
  };

let distinct = l => {
  let rec aux = (l, d) =>
    switch (l) {
    | [head, ...tail] =>
      if (d |> List.exists(u => u == head)) {
        aux(tail, d);
      } else {
        aux(tail, [head, ...d]);
      }
    | [] => d
    };

  aux(l, []);
};

let swap = (index, up, l) => {
  let el = l->List.nth(index);
  let maxIndex = (l |> List.length) - 1;
  l
  |> List.mapi((i, t) =>
       switch (i, up) {
       | (0, true) when index == 0 => t
       | (i, false) when i == maxIndex && index == maxIndex - 1 => el
       | (i, false) when i == maxIndex => t
       | (i, true) when i == index => l->List.nth(index - 1)
       | (i, false) when i == index => l->List.nth(index + 1)
       | (i, true) when i == index - 1 => el
       | (i, false) when i == index + 1 => el
       | (_, _) => t
       }
     );
};
