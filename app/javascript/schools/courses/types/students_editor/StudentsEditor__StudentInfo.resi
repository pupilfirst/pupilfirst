type t

let name: t => string

let email: t => string

let title: t => string

let affiliation: t => string

let toJsObject: (
  ~teamName: string,
  ~tags: array<string>,
  t,
) => {
  "name": string,
  "email": string,
  "tags": array<string>,
  "teamName": option<string>,
  "title": option<string>,
  "affiliation": option<string>,
}

let make: (~name: string, ~email: string, ~title: string, ~affiliation: string) => t
