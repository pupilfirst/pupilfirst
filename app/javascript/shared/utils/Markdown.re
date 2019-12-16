[@bs.module "./markdownIt"] external markdownIt: string => string = "default";
[@bs.module "./sanitize"]
external sanitize: (string, string) => string = "default";

type profile =
  | Comment
  | QuestionAndAnswer
  | Permissive
  | Paragraph;

let profileString = profile =>
  switch (profile) {
  | Comment => "comment"
  | QuestionAndAnswer => "questionAndAnswer"
  | Permissive => "permissive"
  | Paragraph => "paragraph"
  };

let parse = (profile, markdown) =>
  markdown |> markdownIt |> sanitize(profileString(profile));
