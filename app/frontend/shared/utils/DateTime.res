type t = Js.Date.t

let randomId = () => {
  let number = Js.Math.random() |> Js.Float.toString
  let time = Js.Date.now() |> Js.Float.toString
  "I" ++ (time ++ number) |> Js.String.replace(".", "-")
}
