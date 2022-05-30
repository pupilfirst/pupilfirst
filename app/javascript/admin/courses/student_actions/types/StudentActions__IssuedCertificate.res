type t = {
  id: string,
  certificateId: string,
  createdAt: Js.Date.t,
  issuedBy: string,
  revokedAt: option<Js.Date.t>,
  revokedBy: option<string>,
  serialNumber: string,
}

let id = t => t.id
let certificateId = t => t.certificateId
let serialNumber = t => t.serialNumber
let revokedAt = t => t.revokedAt
let issuedBy = t => t.issuedBy
let createdAt = t => t.createdAt
let revokedBy = t => t.revokedBy

let make = (~id, ~certificateId, ~revokedAt, ~revokedBy, ~serialNumber, ~createdAt, ~issuedBy) => {
  id: id,
  certificateId: certificateId,
  revokedAt: revokedAt,
  revokedBy: revokedBy,
  serialNumber: serialNumber,
  createdAt: createdAt,
  issuedBy: issuedBy,
}

module Fragments = %graphql(`
  fragment IssuedCertificateFragment on IssuedCertificate {
    id
    certificate{
      id
    }
    createdAt
    issuedBy
    revokedAt
    revokedBy
    serialNumber
  }
`)

let makeFromFragment = (issuedCertificate: Fragments.t) => {
  id: issuedCertificate.id,
  certificateId: issuedCertificate.certificate.id,
  revokedAt: issuedCertificate.revokedAt->Belt.Option.map(DateFns.decodeISO),
  revokedBy: issuedCertificate.revokedBy,
  serialNumber: issuedCertificate.serialNumber,
  createdAt: issuedCertificate.createdAt->DateFns.decodeISO,
  issuedBy: issuedCertificate.issuedBy,
}

let certificate = (t, certificates) =>
  ArrayUtils.unsafeFind(
    c => StudentActions__Certificate.id(c) == t.certificateId,
    " Unable to find certificate with ID: " ++ t.certificateId,
    certificates,
  )

let revoke = (issuedCertificate, revokedBy, revokedAt) => {
  ...issuedCertificate,
  revokedBy: revokedBy,
  revokedAt: revokedAt,
}
