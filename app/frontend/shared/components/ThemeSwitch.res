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

let getTheme = () => {
  let themePreference =
    Dom.Storage2.localStorage
    ->Dom.Storage2.getItem("themePreference")
    ->Belt.Option.getWithDefault("system")
  themePreference == "system" ? getSystemTheme() : themePreference
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
  getTheme()->applyTheme
}

// Add the DOMContentLoaded listener
Webapi.Dom.window->Webapi.Dom.Window.addEventListener("DOMContentLoaded", _event =>
  setThemeBasedOnPreference()
)
