type t = En | Ru

let toPolymorphic = t =>
  switch t {
  | En => #en
  | Ru => #ru
  }

let all = [En, Ru]

let name = t =>
  switch t {
  | En => "English"
  | Ru => `русский`
  }

let toString = t =>
  switch t {
  | En => "en"
  | Ru => "ru"
  }

let fromString = localeString =>
  switch localeString {
  | "en" => En
  | "ru" => Ru
  | _anyOtherLocaleString => En
  }
