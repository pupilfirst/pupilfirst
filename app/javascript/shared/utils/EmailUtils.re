let regularExpression = [%bs.re
  "/^(([^<>()\\[\\]\\.,;:\\s@\"]+(\\.[^<>()\\[\\]\\.,;:\\s@\"]+)*)|(\".+\"))@(([^<>()[\\]\\.,;:\\s@\"]+\\.)+[^<>()[\\]\\.,;:\\s@\"]{2,})$/i"
];

let isInvalid = (~allowBlank, email) =>
  if (allowBlank && email |> String.trim |> String.length == 0) {
    false;
  } else {
    !(regularExpression |> Js.Re.test(email));
  };