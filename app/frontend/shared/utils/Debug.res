type config = {debug: option<bool>}

@val @scope("window") external config: config = "pupilfirst"

let log = (scope, message) => {
  if Belt.Option.getWithDefault(config.debug, false) {
    Js.log("[" ++ scope ++ "] " ++ message)
  }
}

let error = (scope, message) => {
  Js.Console.error("[" ++ scope ++ "] " ++ message)
}
