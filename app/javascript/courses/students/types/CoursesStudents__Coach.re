type t = {
  id: string,
  name: string,
  title: string,
  avatarUrl: option(string),
};

let make = (~id, ~name, ~title, ~avatarUrl) => {id, name, title, avatarUrl};

let id = t => t.id;

let name = t => t.name;

let title = t => t.title;

let avatarUrl = t => t.avatarUrl;

let makeFromJs = coachData => {
  make(
    ~id=coachData##id,
    ~name=coachData##name,
    ~title=coachData##title,
    ~avatarUrl=coachData##avatarUrl,
  );
};
