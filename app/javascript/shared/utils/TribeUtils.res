type kind = string

type options = {
  id: string,
  slug: string,
  components: array<string>,
  feedLimit: int,
}

@bs.val @bs.scope("window") external tribe: (kind, options) => unit = "Tribe"
let tribe = (id, kind, slug) => {
  let opts = {
    id,
    slug,
    components: ["feed", "input", "header"],
    feedLimit: 5,
  }
  tribe(kind, opts)
}