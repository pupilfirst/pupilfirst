%graphql(
  `
  fragment AllFragments on UserProxy {
    id
    name
    userId
    title
    avatarUrl
  }
`
  {inline: true}
)
