exception UnsafeFindFailed(string)

let isEmpty = l =>
  switch l {
  | list{_h, ..._t} => false
  | list{} => true
  }

let isNotEmpty = l => !isEmpty(l)

let findOpt = (p, l) =>
  try Some(List.find(p, l)) catch {
  | Not_found => None
  }

let unsafeFind = (p, message, l) =>
  try List.find(p, l) catch {
  | Not_found =>
    Rollbar.error(message)
    raise(UnsafeFindFailed(message))
  }

let distinct = l => {
  let rec aux = (l, d) =>
    switch l {
    | list{head, ...tail} =>
      if d->Belt.List.some(u => u == head) {
        aux(tail, d)
      } else {
        aux(tail, list{head, ...d})
      }
    | list{} => d
    }

  aux(l, list{})
}

let swapDown = (e, l) => {
  let rec aux = (prev, l, e) =>
    switch l {
    | list{head, next, ...tail} if head == e => Belt.List.concat(prev, list{next, head, ...tail})
    | list{head, ...tail} => aux(Belt.List.concat(prev, list{head}), tail, e)
    | list{} => prev
    }

  aux(list{}, l, e)
}

let swapUp = (e, l) => List.reverse(swapDown(e, List.reverse(l)))

let swap = (up, e, l) => up ? swapUp(e, l) : swapDown(e, l)
