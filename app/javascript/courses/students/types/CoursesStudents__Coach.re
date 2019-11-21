type t = {
  id: string,
  name: string,
  title: string,
  avatarUrl: option(string),
};

let make = (~id, ~name, ~title, ~avatarUrl) => {id, name, title, avatarUrl};

let makeFromJs = coachData => {
  make(
    ~id=coachData##id,
    ~name=coachData##name,
    ~title=coachData##title,
    ~avatarUrl=coachData##avatarUrl,
  );
};
