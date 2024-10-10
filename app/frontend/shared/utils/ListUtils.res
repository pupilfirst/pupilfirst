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
