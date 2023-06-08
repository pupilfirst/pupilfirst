type t

let decode: Js.Json.t => t

let name: t => string

let id: t => string

let imageUrl: t => string

let email: t => string

let title: t => string

let public: t => bool

let connectLink: t => option<string>

let exited: t => bool

let affiliation: t => option<string>

let imageFileName: t => option<string>

let make: (
  ~id: string,
  ~name: string,
  ~imageUrl: string,
  ~email: string,
  ~title: string,
  ~public: bool,
  ~connectLink: option<string>,
  ~exited: bool,
  ~imageFileName: option<string>,
  ~affiliation: option<string>,
) => t
