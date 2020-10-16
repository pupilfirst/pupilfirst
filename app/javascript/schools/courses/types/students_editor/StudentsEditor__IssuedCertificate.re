type t = {
  id: string,
  certificateId: string,
  revokedAt: option(Js.Date.t),
  revokedBy: option(string),
  serialNumber: string,
};

let id = t => t.id;

let certificateId = t => t.certificateId;

let revokedAt = t => t.revokedAt;

let revokedBy = t => t.revokedBy;

let make = (~id, ~certificateId, ~revokedAt, ~revokedBy, ~serialNumber) => {
  id,
  certificateId,
  revokedAt,
  revokedBy,
  serialNumber,
};

let makeFromJS = data => {
  make(
    ~id=data##id,
    ~certificateId=data##certificateId,
    ~revokedAt=data##revokedAt->Belt.Option.map(DateFns.decodeISO),
    ~revokedBy=data##revokedBy,
    ~serialNumber=data##serialNumber,
  );
};
