[@bs.config {jsx: 3}];

let str = React.string;

open CourseShow__Types;

let renderBlockClasses = block =>
  switch (block |> ContentBlock.blockType) {
  | Markdown(_) => "mt-4"
  | File(_) => "mt-4"
  | Image(_) => "mt-4"
  | Embed(_) => "flex justify-center mt-4"
  };

let markdownContentBlock = markdown => <MarkdownBlock markdown className="" />;

let fileContentBlock = (url, title, filename) =>
  <div className="mt-2 shadow-md border px-6 py-4 rounded-lg">
    <a className="flex justify-between items-center" href=url>
      <div className="flex items-center">
        <FaIcon classes="text-4xl text-red-600 fal fa-file-pdf" />
        <div className="pl-4 leading-tight">
          <div className="text-lg font-semibold"> {title |> str} </div>
          <div className="text-sm italic text-gray-600">
            {filename |> str}
          </div>
        </div>
      </div>
      <div> <FaIcon classes="text-2xl far fa-download" /> </div>
    </a>
  </div>;

let imageContentBlock = (url, caption) =>
  <div className="rounded-lg bg-gray-300">
    <img src=url alt=caption />
    <div className="px-4 py-2 text-sm italic"> {caption |> str} </div>
  </div>;

let embedContentBlock = (_url, embedCode) =>
  <div dangerouslySetInnerHTML={"__html": embedCode} />;

[@react.component]
let make = (~target, ~targetDetails, ~authenticityToken, ~targetStatus) =>
  <div>
    {
      targetDetails
      |> TargetDetails.contentBlocks
      |> ContentBlock.sort
      |> List.map(block => {
           let renderedBlock =
             switch (block |> ContentBlock.blockType) {
             | Markdown(markdown) => markdownContentBlock(markdown)
             | File(url, title, filename) =>
               fileContentBlock(url, title, filename)
             | Image(url, caption) => imageContentBlock(url, caption)
             | Embed(url, embedCode) => embedContentBlock(url, embedCode)
             };

           <div
             className={renderBlockClasses(block)}
             key={block |> ContentBlock.id}>
             renderedBlock
           </div>;
         })
      |> Array.of_list
      |> React.array
    }
    {
      switch (TargetDetails.computeCompletionType(targetDetails)) {
      | LinkToComplete
      | MarkAsComplete =>
        <CourseShow__AutoVerify
          target
          targetDetails
          authenticityToken
          targetStatus
        />
      | _ => React.null
      }
    }
  </div>;