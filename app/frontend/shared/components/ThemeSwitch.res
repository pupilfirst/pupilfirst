// Define a type for the mediaQueryList object
type mediaQueryList = {matches: bool}

// Binding to window.matchMedia
@val external matchMedia: string => mediaQueryList = "window.matchMedia"

let getSystemTheme = () => {
  if matchMedia("(prefers-color-scheme: dark)").matches {
    "dark"
  } else {
    "light"
  }
}

let applyTheme = theme => {
  let root = Webapi.Dom.document->Webapi.Dom.Document.documentElement
  switch theme {
  | "dark" => root->Webapi.Dom.Element.classList->Webapi.Dom.DomTokenList.add("dark")
  | "light" => root->Webapi.Dom.Element.classList->Webapi.Dom.DomTokenList.remove("dark")
  | _ => () // Do nothing for other cases
  }
}

let setThemeBasedOnPreference = () => {
  let themePreference = Dom.Storage2.getItem(Dom.Storage2.localStorage, "themePreference")
  switch themePreference {
  | Some("dark") | Some("light") => applyTheme(themePreference->Belt.Option.getExn)
  | Some("system") => getSystemTheme()->applyTheme
  | None => getSystemTheme()->applyTheme
  | _ => () // Do nothing for other cases
  }
}

// Add the DOMContentLoaded listener
Webapi.Dom.window->Webapi.Dom.Window.addEventListener("DOMContentLoaded", _event =>
  setThemeBasedOnPreference()
)
