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

let swapDown = (l, head) => {
  let rec aux = (prev, l, head) =>
    switch (l) {
    | [] => prev
    | [hd, ...fullTail] =>
      switch (fullTail) {
      | [] => prev @ [hd]
      | [nxt, ...partTail] when hd == head => prev @ [nxt, hd, ...partTail]
      | [nxt, ...partTail] => aux(prev @ [hd], fullTail, head)
      }
    };

  aux([], l, head);
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
  /* swapDown(l, el); */
};

/* prev = []
   [hd, nxt, ...tail]


   [...prev, nxt, hd, ...tail]


   [hd, []] => [...prev, hd] */
