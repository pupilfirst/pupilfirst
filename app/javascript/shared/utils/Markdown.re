[@bs.module "./markdown"] external parseFunction: string => string = "default";

let parse = markdown => markdown |> parseFunction;