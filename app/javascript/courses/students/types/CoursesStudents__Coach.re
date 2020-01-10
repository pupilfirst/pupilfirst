type t = {
  name: string,
  title: string,
  avatarUrl: option(string),
  userId: string,
};

let name = t => t.name;

let title = t => t.title;

let avatarUrl = t => t.avatarUrl;

let userId = t => t.userId;

let make = (~name, ~title, ~avatarUrl, ~userId) => {
  name,
  title,
  avatarUrl,
  userId,
};

let makeFromJs = coachData => {
  make(
    ~name=coachData##name,
    ~title=coachData##title,
    ~avatarUrl=coachData##avatarUrl,
    ~userId=coachData##userId,
  );
};
