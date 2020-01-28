let confirm = (message, f) =>
  Webapi.Dom.(window |> Window.confirm(message)) ? f() : ();
