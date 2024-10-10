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
