exception UnsafeFindFailed(string)

@deprecated("Use Array.toSorted instead")
let copyAndSort = (f, t) => {
  let cp = Js.Array2.copy(t)
  Js.Array2.sortInPlaceWith(cp, f)
}

let copyAndPush = (e, t) => {
  let copy = Array.copy(t)
  copy->Array.push(e)
  copy
}

let isEmpty = a => Array.length(a) == 0

let isNotEmpty = a => !isEmpty(a)

let unsafeFind = (checker, message, array) =>
  switch Array.find(array, checker) {
  | Some(e) => e
  | None =>
    Notification.error(
      "An unexpected error occurred",
      "Our team has been notified about this error. Please try reloading this page.",
    )
    raise(UnsafeFindFailed(message))
  }

let replaceWithIndex = (i, t, l) => Js.Array.mapi((a, index) => index == i ? t : a, l)

let distinct = t => Set.fromArray(t)->Set.values->Array.fromIterator

let sortUniq = (f, t) => t->Array.toSorted(f)->Set.fromArray->Set.values->Array.fromIterator

let swapUp = (i, t) =>
  if i <= 0 || i >= Array.length(t) {
    Rollbar.warning("Index to swap out of bounds in array!")
    t
  } else {
    let copy = Js.Array.copy(t)

    Array.setUnsafe(copy, i, Array.getUnsafe(t, i - 1))
    Array.setUnsafe(copy, i - 1, Array.getUnsafe(t, i))

    copy
  }

let swapDown = (i, t) => swapUp(i + 1, t)

let last = t => Array.getUnsafe(t, Array.length(t) - 1)
