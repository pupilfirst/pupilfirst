let iso8601 = t => t |> DateFns.format("YYYY-MM-DD");

let iso8601Option = optionalDate =>
  switch (optionalDate) {
  | Some(date) => Some(date |> iso8601)
  | None => None
  };

let parseOption = optionalString =>
  switch (optionalString) {
  | Some(dateString) => Some(DateFns.parseString(dateString))
  | None => None
  };
