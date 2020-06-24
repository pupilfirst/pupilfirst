exception UnexpectedStatus(string);

type status =
  | ConfirmationPending(option(Js.Date.t))
  | Confirmed(Js.Date.t);

type t = {
  email: string,
  status,
};

let email = t => t.email;

let decode = json => {
  let status =
    switch (json |> Json.Decode.(field("status", string))) {
    | "confirmed" =>
      let confirmedAt =
        json |> Json.Decode.(field("confirmedAt", DateFns.decodeISO));
      Confirmed(confirmedAt);
    | "confirmationPending" =>
      let lastCheckedAt =
        json
        |> Json.Decode.(optional(field("lastCheckedAt", DateFns.decodeISO)));
      ConfirmationPending(lastCheckedAt);
    | otherStatus =>
      Rollbar.error(
        "Encountered unexpected status value when decoding fromAddress: "
        ++ otherStatus,
      );
      raise(UnexpectedStatus(otherStatus));
    };

  Json.Decode.{email: json |> field("email", string), status};
};
