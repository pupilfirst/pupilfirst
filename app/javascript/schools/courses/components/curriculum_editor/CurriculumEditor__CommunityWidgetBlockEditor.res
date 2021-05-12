let str = React.string

let onChangeSlug = (contentBlock, kind, updateContentBlockCB, event) => {
  event |> ReactEvent.Form.preventDefault
  let value = ReactEvent.Form.target(event)["value"]
  let newContentBlock = contentBlock |> ContentBlock.updateCommunityWidget(kind, value)
  updateContentBlockCB(newContentBlock)
}

@react.component
let make = (~kind, ~slug, ~contentBlock, ~updateContentBlockCB) => {
  let kindInputId = "kind-" ++ (contentBlock |> ContentBlock.id)
  let slugInputId = "slug-" ++ (contentBlock |> ContentBlock.id)

  <div className="relative border border-gray-400 rounded-lg">
    <div className="flex border-t justify-end">
      <div className="flex-1 content-block__action-bar-input p-3">
        <label htmlFor=slugInputId className="text-sm font-semibold"> {"Slug" |> str} </label>
        <input
          id=slugInputId
          className="mt-1 appearance-none block w-full h-10 bg-white text-gray-800 border rounded py-3 px-3 focus:border-gray-400 leading-tight focus:outline-none focus:bg-white focus:border-gray"
          onChange={onChangeSlug(contentBlock, kind, updateContentBlockCB)}
          type_="text"
          value=slug
          placeholder="community item slug here"
        />
      </div>
    </div>
  </div>
}
