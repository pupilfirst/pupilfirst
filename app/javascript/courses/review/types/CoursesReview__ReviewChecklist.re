type t = {
  title: string,
  checklist: array(CoursesReview__ReviewChecklistResult.t),
};
let title = t => t.title;
let checklist = t => t.checklist;

let make = (~title, ~checklist) => {title, checklist};

let decodeJS = data => {
  data
  |> Js.Array.map(rc =>
       make(
         ~title=rc##title,
         ~checklist=
           rc##checklist |> CoursesReview__ReviewChecklistResult.decodeJS,
       )
     );
};
