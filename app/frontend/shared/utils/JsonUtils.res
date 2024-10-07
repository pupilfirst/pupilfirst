exception DecodeError(string)

@unboxed
type rec json =
  | @as(null) Null
  | Boolean(bool)
  | String(string)
  | Number(float)
  | Object(Dict.t<json>)
  | Array(array<json>)

@scope("JSON") @val
external parse: string => json = "parse"

let parseTimestamp = (dict, key, caller) =>
  switch dict->Dict.get(key) {
  | Some(String(timestamp)) => DateFns.parseISO(timestamp)
  | Some(_) => raise(DecodeError(caller ++ " called with non-string " ++ key))
  | None => raise(DecodeError(caller ++ " was called without " ++ key))
  }

let string = (dict, key, caller) => {
  switch dict->Dict.get(key) {
  | Some(String(string)) => string
  | Some(_) => raise(DecodeError(caller ++ " called with non-string " ++ key))
  | None => raise(DecodeError(caller ++ " was called without " ++ key))
  }
}
