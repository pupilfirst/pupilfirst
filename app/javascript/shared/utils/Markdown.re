[@bs.module "./markdownIt"] external markdownIt: string => string = "default";
[@bs.module "./sanitize"]
external sanitize: (string, string) => string = "default";

type profile =
  | Comment
  | QuestionAndAnswer
  | Permissive;

let profileString = profile =>
  switch (profile) {
  | Comment => "comment"
  | QuestionAndAnswer => "questionsAndAnswer"
  | Permissive => "permissive"
  };

let parse = (profile, markdown) =>
  markdown |> markdownIt |> sanitize(profileString(profile));