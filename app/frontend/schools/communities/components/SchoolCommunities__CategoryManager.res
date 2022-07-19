let str = React.string

let tr = I18n.t(~scope="components.SchoolCommunities__CategoryManager")

open SchoolCommunities__IndexTypes

@react.component
let make = (~community, ~deleteCategoryCB, ~createCategoryCB, ~updateCategoryCB, ~setDirtyCB) => {
  let categories = Community.topicCategories(community)
  <div className="mx-8 pt-8">
    <h5 className="uppercase text-center border-b border-gray-300 pb-2">
      {tr("categories_in") ++ " " ++ Community.name(community) |> str}
    </h5>
    {ReactUtils.nullIf(
      <div className="mb-2 flex flex-col">
        {categories
        |> Js.Array.map(category =>
          <SchoolCommunities__CategoryEditor
            key={Category.id(category)}
            category
            communityId={Community.id(community)}
            deleteCategoryCB
            createCategoryCB
            updateCategoryCB
            setDirtyCB
          />
        )
        |> React.array}
      </div>,
      ArrayUtils.isEmpty(categories),
    )}
    <SchoolCommunities__CategoryEditor
      communityId={Community.id(community)}
      deleteCategoryCB
      createCategoryCB
      updateCategoryCB
      setDirtyCB
    />
  </div>
}
