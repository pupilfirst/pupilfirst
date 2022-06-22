let stringRepeat = (n, s) => s |> Array.make(n) |> Array.to_list |> String.concat("")

Psj.match("home#styleguide", () => {
  switch ReactDOM.querySelector("#styleguide__markdown-syntax-highlighting-root") {
  | Some(root) => ReactDOM.render(<HomeStyleguide__MarkdownSyntaxHighlightingPreview />, root)
  | None => ()
  }

  switch ReactDOM.querySelector("#styleguide__skeleton-loading-root") {
  | Some(root) => ReactDOM.render(<HomeStyleguide__SkeletonLoadingPreview />, root)
  | None => ()
  }

  switch ReactDOM.querySelector("#styleguide__disabling-cover-root") {
  | Some(root) =>
    ReactDOM.render(
      <DisablingCover
        disabled=true message="This element is disabled, and this is a custom message.">
        <div className="m-2 p-2 border-2 border-red-500">
          {"This is the element being disabled. " |> stringRepeat(10) |> React.string}
        </div>
      </DisablingCover>,
      root,
    )
  | None => ()
  }
})
