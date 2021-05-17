type kind = string

@bs.val @bs.scope("window") external tribe: (kind, Js.t<'a>) => unit = "Tribe"
let tribe = (id, kind, slug) => {
  let components = switch kind {
    | "group" => ["feed", "input", "header"]
    | "post" => ["post", "responses"]
    | "question" => ["question", "answers", "relatedQuestions"]
    | _ => []
  }
  switch kind {
    | "group" => tribe(kind, {"id": id, "slug": slug, "components": components, "feedLimit": 5})
    | "post" => tribe(kind, {"id": id, "postId": slug, "components": components })
    | "question" => tribe(kind, {"id": id, "questionId": slug, "components": components })
    | _ => tribe("group", {"id": id, "slug": slug})
  }
}