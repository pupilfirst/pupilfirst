open Webapi.Dom

@scope("Document") @val external readyState: string = "readyState"

let log = Debug.log("PSJ")

let ready = f => {
  if readyState != "loading" {
    f()
  } else {
    Document.addEventListener(document, "DOMContentLoaded", _event => f())
  }
}

let match = (~onReady=true, path, f) => {
  log("Try to match " ++ path)

  let pathFragments = Js.String2.split(path, "#")

  if pathFragments->Js.Array2.length != 2 {
    Debug.error(
      "PSJ",
      "Path must be of the format `controller#action` or `module/controller#action`. Received: " ++
      path,
    )
  } else {
    let metaTag = document->Document.querySelector("meta[name='psj']")

    switch metaTag {
    | None => ()
    | Some(tag) =>
      let controller = Element.getAttribute(tag, "controller")
      let action = Element.getAttribute(tag, "action")

      switch (controller, action) {
      | (Some(controller), Some(action)) =>
        if controller == pathFragments[0] && action == pathFragments[1] {
          log("Matched " ++ path)
          onReady ? ready(f) : f()
        }
      | (None, Some(_)) => Debug.error("PSJ", "Meta tag is missing the controller prop.")
      | (Some(_), None) => Debug.error("PSJ", "Meta tag is missing the action prop.")
      | (None, None) =>
        Debug.error("PSJ", "Meta tag is missing both the controller or action prop.")
      }
    }
  }
}

let sanitizePath = path => {
  path->Js.String2.replaceByRe(%re("/^\//"), "")->Js.String2.replaceByRe(%re("/\/$/"), "")
}

let matchPaths = (~onReady=true, paths, f) => {
  log("Try to match paths " ++ Js.Array2.joinWith(paths, ", "))

  let _ = Js.Array2.some(paths, path => {
    let pathFragments = Js.String2.split(path, "/")
    let currentPathFragments = Location.pathname(location)->sanitizePath->Js.String2.split("/")

    if Js.Array2.length(pathFragments) == Js.Array2.length(currentPathFragments) {
      let matched = Js.Array2.everyi(pathFragments, (fragment, index) => {
        if fragment == "*" || Js.String2.charAt(fragment, 0) == ":" {
          true
        } else if fragment == currentPathFragments[index] {
          true
        } else {
          false
        }
      })

      if matched {
        log("Matched " ++ path)
        onReady ? ready(f) : f()
      }

      matched
    } else {
      false
    }
  })
}
