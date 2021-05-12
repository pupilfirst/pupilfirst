let str = React.string

let onChangeWidget = (contentBlock, updateContentBlockCB, slug, kind, _) => {
  let newContentBlock = contentBlock |> ContentBlock.updateCommunityWidget(kind, slug)
  updateContentBlockCB(newContentBlock)
}

let onChangeSlug = (contentBlock, kind, updateContentBlockCB, event) => {
  event |> ReactEvent.Form.preventDefault
  let value = ReactEvent.Form.target(event)["value"]
  onChangeWidget(contentBlock, updateContentBlockCB, value, kind, ())
}

@react.component
let make = (~kind, ~slug, ~contentBlock, ~updateContentBlockCB) => {
  let kindInputId = "kind-" ++ (contentBlock |> ContentBlock.id)
  let slugInputId = "slug-" ++ (contentBlock |> ContentBlock.id)

  let handleChangeKind = onChangeWidget(contentBlock, updateContentBlockCB, slug)
  let activeClass = (buttonKind) => switch kind == buttonKind {
  | true => "toggle-button__button--active"
  | _ => ""
  }

  let toggleButton = (buttonKind) => {
    let text = switch buttonKind {
    | "group" => "Group"
    | "question" => "Question"
    | "post" => "Post"
    | _ => "Invalid"
    }

    <button onClick={handleChangeKind(buttonKind)}
      className={"toggle-button__button " ++ activeClass(buttonKind)}>
      { text |> str }
    </button>
  }

  <div className="relative border border-gray-400 rounded-lg">
    <div className="flex-col border-t justify-end">
      <div className="flex-col items-center flex-shrink-0 p-3">
        <label htmlFor={kindInputId} className="block tracking-wide text-sm font-semibold mr-3">
          {"Widget type" |> str}
        </label>
        <div className="mt-1 flex toggle-button__group flex-shrink-0 rounded-lg" id={kindInputId}>
          {toggleButton("group")}
          {toggleButton("post")}
          {toggleButton("question")}
        </div>
      </div>
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
