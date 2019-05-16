[@bs.module "./markdownIt"] external markdownIt: string => string = "default";
[@bs.module "./sanitize"] external sanitize: string => string = "default";

let parse = markdown => markdown |> markdownIt;
/* let parse = markdown => markdown |> markdownIt |> sanitize; */