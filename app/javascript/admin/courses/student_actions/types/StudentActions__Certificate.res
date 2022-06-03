type t = {
  id: string,
  name: string,
  active: bool,
}

let id = t => t.id

let name = t => t.name

let active = t => t.active

module Fragment = %graphql(`
  fragment CertificateFragment on Certificate {
    id
    name
    active
  }
`)

let makeFromFragment = (certificate: Fragment.t) => {
  id: certificate.id,
  name: certificate.name,
  active: certificate.active,
}

let make = (id: string, name: string, active: bool) => {
  id: id,
  name: name,
  active: active,
}
