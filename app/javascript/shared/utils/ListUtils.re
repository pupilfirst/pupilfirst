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