let isEmpty = l =>
  switch (l) {
  | [_h, ..._t] => true
  | [] => false
  };

let findOpt = (p, l) =>
  try (Some(List.find(p, l))) {
  | Not_found => None
  };