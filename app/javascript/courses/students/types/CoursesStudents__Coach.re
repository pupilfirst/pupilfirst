type t = {
  name: string,
  title: string,
  avatarUrl: option(string),
};

let name = t => t.name;

let title = t => t.title;

let avatarUrl = t => t.avatarUrl;

let make = (~name, ~title, ~avatarUrl) => {name, title, avatarUrl};

let makeFromJs = coachData => {
  make(
    ~name=coachData##name,
    ~title=coachData##title,
    ~avatarUrl=coachData##avatarUrl,
  );
};
