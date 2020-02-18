type t = {
  userId: string,
  name: string,
  title: string,
  avatarUrl: option(string),
};

let userId = t => t.userId;
let name = t => t.name;
let title = t => t.title;
let avatarUrl = t => t.avatarUrl;

let decode = json =>
  Json.Decode.{
    userId: json |> field("userId", string),
    name: json |> field("name", string),
    title: json |> field("title", string),
    avatarUrl: json |> optional(field("avatarUrl", string)),
  };

let coachesForTeam = (team, ts) => {
  ts
  |> Js.Array.filter(t =>
       team |> CoursesStudents__TeamInfo.coachUserIds |> Array.mem(t.userId)
     );
};
