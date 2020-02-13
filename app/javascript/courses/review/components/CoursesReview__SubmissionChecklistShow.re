[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

let showlink = link =>
  <a
    href=link
    target="_blank"
    className="max-w-fc mt-2 mr-3 flex items-center border overflow-hidden shadow rounded hover:shadow-md border-blue-400 bg-blue-200 text-blue-700 hover:border-blue-600 hover:text-blue-800">
    <span
      className="flex h-full w-8 justify-center items-center p-2 bg-blue-200">
      <i className="fas fa-link" />
    </span>
    <span
      className="course-show-attachments__attachment-title rounded text-xs font-semibold inline-block whitespace-normal truncate w-32 md:w-42 h-full px-3 py-1 leading-loose bg-blue-100">
      {link |> str}
    </span>
  </a>;

[@react.component]
let make = (~checklist) => {
  <div>
    {checklist
     |> Array.map(c => {
          <div className="mt-2 ">
            <div className="text-sm font-semibold flex justify-between">
              <div>
                <span> <i className="fas fa-link" /> </span>
                <span className="ml-2 md:ml-3 tracking-wide">
                  {c |> Checklist.title |> str}
                </span>
              </div>
              <div className="inline-block">
                <i className="fas fa-check" />
              </div>
            </div>
            <div className="ml-6 md:ml-7 hidden">
              <div>
                {switch (c |> Checklist.result) {
                 | ShortText(text) => <div> {text |> str} </div>
                 | LongText(markdown) =>
                   <MarkdownBlock profile=Markdown.Permissive markdown />
                 | Link(link) => showlink(link)
                 | MultiChoice(text) => <div> {text |> str} </div>
                 | Files(files) => <div> {"Handle Files" |> str} </div>
                 | None => <div> {"Handle Empty" |> str} </div>
                 }}
              </div>
              <div
                className="bg-white border border-green-500 rounded-lg px-1 py-px inline-block text-green-500 text-xs">
                {"Passed" |> str}
              </div>
            </div>
          </div>
        })
     |> React.array}
  </div>;
};
