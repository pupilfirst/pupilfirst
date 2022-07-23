type t =
  | Reloading(array<bool>)
  | LoadingMore

let setReloading = t => {
  switch t {
  | LoadingMore => Reloading([true])
  | Reloading(times) => {
      times->Js.Array2.push(true)->ignore
      Reloading(times)
    }
  }
}

let setNotLoading = t => {
  switch t {
  | LoadingMore => Reloading([])
  | Reloading(times) => {
      times->Js.Array2.pop->ignore
      Reloading(times)
    }
  }
}

let empty = () => {
  Reloading([])
}
