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