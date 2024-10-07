exception UnsafeFindFailed(string)

let copyAndSort = (f, t) => {
  let cp = Js.Array.copy(t)
  Js.Array.sortInPlaceWith(f, cp)
}

let copyAndPush = (e, t) => {
  let copy = Js.Array.copy(t)
  ignore(Js.Array.push(e, copy))
  copy
}

let isEmpty = a => Js.Array.length(a) == 0

let isNotEmpty = a => !isEmpty(a)

let unsafeFind = (p, message, l) =>
  switch Js.Array.find(p, l) {
  | Some(e) => e
  | None =>
    Rollbar.error(message)
    Notification.error(
      "An unexpected error occurred",
      "Our team has been notified about this error. Please try reloading this page.",
    )
    raise(UnsafeFindFailed(message))
  }

let replaceWithIndex = (i, t, l) => Js.Array.mapi((a, index) => index == i ? t : a, l)

let flattenV2 = a => Array.flat(a)

let distinct = t => List.toArray(ListUtils.distinct(List.fromArray(t)))

let sortUniq = (f, t) => t->Array.toSorted(f)->Set.fromArray->Set.values->Array.fromIterator

let getOpt = (a, i) =>
  try {
    Some(a->Array.get(i))
  } catch {
  | Not_found => None
  | Invalid_argument(_) => None
  }

let swapUp = (i, t) =>
  if i <= 0 || i >= Array.length(t) {
    Rollbar.warning("Index to swap out of bounds in array!")
    t
  } else {
    let copy = Js.Array.copy(t)

    copy[i] = t[i - 1]
    copy[i - 1] = t[i]
    copy
  }

let swapDown = (i, t) => swapUp(i + 1, t)

let last = t => t->Js.Array.unsafe_get(Js.Array.length(t) - 1)
