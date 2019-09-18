type t = {
  createdAt: string,
  value: string,
  id: string,
  coachName: string,
  coachAvatarUrl: string,
  coachTitle: option(string),
};
let value = t => t.value;
let coachName = t => t.coachName;
let coachAvatarUrl = t => t.coachAvatarUrl;
let coachTitle = t => t.coachTitle;

let createdAt = t => t.coachTitle;

let make = (~coachName, ~coachAvatarUrl, ~coachTitle, ~createdAt, ~value, ~id) => {
  coachName,
  coachAvatarUrl,
  coachTitle,
  createdAt,
  value,
  id,
};
