type key = string
type value = string

let t: (~scope: string=?, ~variables: array<(key, value)>=?, ~count: int=?, string) => string
