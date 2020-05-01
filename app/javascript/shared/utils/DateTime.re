type t = Js.Date.t;

type format =
  | OnlyDate
  | DateWithYearAndTime;

let format = (f, t) => {
  let formatString =
    switch (f) {
    | OnlyDate => "MMM d, yyyy"
    | DateWithYearAndTime => "do MMM yyyy HH:mm"
    };

  DateFns.format(t, formatString);
};

let randomId = () => {
  let number = Js.Math.random() |> Js.Float.toString;
  let time = Js.Date.now() |> Js.Float.toString;
  "I" ++ time ++ number |> Js.String.replace(".", "-");
};
