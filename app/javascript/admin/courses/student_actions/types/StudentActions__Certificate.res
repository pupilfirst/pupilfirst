type t = {
  id: string,
  name: string,
  active: bool,
}

let id = t => t.id

let name = t => t.name

let active = t => t.active

module Fragments = %graphql(`
  fragment CertificateFragment on Certificate {
    id
    name
    active
  }
`)

let makeFromFragment = (certificate: Fragments.t) => {
  id: certificate.id,
  name: certificate.name,
  active: certificate.active,
}
