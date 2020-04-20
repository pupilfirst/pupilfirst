let paramToId = param => {
  [%re "/^\d+/g"]
  ->Js.Re.exec_(param)
  ->Belt.Option.map(Js.Re.captures)
  ->Belt.Option.map(Js.Array.joinWith(""));
};
