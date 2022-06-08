open Webapi.Dom

@scope("Document") @val external readyState: string = "readyState"

let ready = f => {
  if readyState != "loading" {
    f()
  } else {
    Document.addEventListener("DOMContentLoaded", _event => f(), document)
  }
}

let match = (~onReady=true, path, f) => {
  let pathFragments = Js.String2.split(path, "#")

  if pathFragments->Js.Array2.length != 2 {
    Js.Console.error(
      "[PSJ] Path must be of the format `controller#action` or `module/controller#action`. Received: " ++
      path,
    )
  } else {
    let metaTag = document |> Document.querySelector("meta[name='psj']")

    switch metaTag {
    | None => ()
    | Some(tag) =>
      let controller = Element.getAttribute("controller", tag)
      let action = Element.getAttribute("action", tag)

      switch (controller, action) {
      | (Some(controller), Some(action)) =>
        if controller == pathFragments[0] && action == pathFragments[1] {
          Js.log("[PSJ] Matched " ++ path)
          onReady ? ready(f) : f()
        }
      | (None, Some(_)) => Js.Console.error("[PSJ] Meta tag is missing the controller prop.")
      | (Some(_), None) => Js.Console.error("[PSJ] Meta tag is missing the action prop.")
      | (None, None) =>
        Js.Console.error("[PSJ] Meta tag is missing both the controller or action prop.")
      }
    }
  }
}
