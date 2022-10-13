type t = {
  id: string,
  certificate: StudentActions__Certificate.t,
  createdAt: Js.Date.t,
  issuedBy: string,
  revokedAt: option<Js.Date.t>,
  revokedBy: option<string>,
  serialNumber: string,
}

let id = t => t.id
let certificate = t => t.certificate
let serialNumber = t => t.serialNumber
let revokedAt = t => t.revokedAt
let issuedBy = t => t.issuedBy
let createdAt = t => t.createdAt
let revokedBy = t => t.revokedBy

let make = (~id, ~certificate, ~revokedAt, ~revokedBy, ~serialNumber, ~createdAt, ~issuedBy) => {
  id: id,
  certificate: certificate,
  revokedAt: revokedAt,
  revokedBy: revokedBy,
  serialNumber: serialNumber,
  createdAt: createdAt,
  issuedBy: issuedBy,
}

module CertificateFragment = StudentActions__Certificate.Fragment
module Fragment = %graphql(`
  fragment IssuedCertificateFragment on IssuedCertificate {
    id
    certificate{
      id
      name
      active
    }
    createdAt
    issuedBy
    revokedAt
    revokedBy
    serialNumber
  }
`)

let makeFromFragment = (issuedCertificate: Fragment.t) => {
  id: issuedCertificate.id,
  certificate: StudentActions__Certificate.make(
    issuedCertificate.certificate.id,
    issuedCertificate.certificate.name,
    issuedCertificate.certificate.active,
  ),
  revokedAt: issuedCertificate.revokedAt->Belt.Option.map(DateFns.decodeISO),
  revokedBy: issuedCertificate.revokedBy,
  serialNumber: issuedCertificate.serialNumber,
  createdAt: issuedCertificate.createdAt->DateFns.decodeISO,
  issuedBy: issuedCertificate.issuedBy,
}

let revoke = (issuedCertificate, revokedBy, revokedAt) => {
  ...issuedCertificate,
  revokedBy: revokedBy,
  revokedAt: revokedAt,
}
