open CommunitiesShow__Types;

let str = React.string;

[@react.component]
let make = (~target, ~topics, ~showPrevPage, ~showNextPage) => {
  <div className="flex-1 flex flex-col">
    {switch (target) {
     | Some(target) =>
       <div className="max-w-3xl w-full mt-5 mx-auto px-3 md:px-0">
         <div
           className="flex py-4 px-4 md:px-6 w-full bg-yellow-100 border border-dashed border-yellow-400 rounded justify-between items-center">
           <p className="w-3/5 md:w-4/5 font-semibold text-sm">
             {"Target: " ++ Target.title(target) |> str}
           </p>
           <a
             className="no-underline bg-yellow-100 border border-yellow-400 px-3 py-2 hover:bg-yellow-200 rounded-lg cursor-pointer text-xs font-semibold"
             href="community_path">
             {"Clear Filter" |> str}
           </a>
         </div>
       </div>
     | None => React.null
     }}
    <div
      className="community-ask-button-container flex max-w-3xl mx-auto px-6 mt-10 items-center justify-center w-full relative">
      <div className="bg-gray-100 px-1 z-10">
        <a
          className="no-underline btn btn-primary btn-large"
          href="new_topic_path">
          <i className="fas fa-plus-circle text-lg" />
          <span className="font-semibold ml-2">
            {"Create a new topic" |> str}
          </span>
        </a>
      </div>
    </div>
    <div className="px-3 md:px-6 pb-4 mt-5 flex flex-1">
      <div className="max-w-3xl w-full mx-auto relative">
        <div
          className="community-question__list-container shadow bg-white rounded-lg mb-4">
          {topics
           |> Array.map(topic =>
                <div
                  className="flex items-center border-b"
                  ariaLabel="Topic <%= topic.id %>">
                  <div className="flex w-full">
                    <a
                      className="cursor-pointer no-underline flex flex-1 justify-between items-center p-4 md:p-6 hover:bg-gray-100 hover:text-primary-500 border border-transparent hover:border-primary-400"
                      href={"/topics/" ++ Topic.id(topic)}>
                      <span className="block">
                        <span
                          className="community-question__title text-sm md:text-base font-semibold inline-block break-words leading-snug">
                          {Topic.title(topic) |> str}
                        </span>
                        <span className="block text-xs mt-1">
                          <span> {"Asked by " |> str} </span>
                          <span className="font-semibold">
                            {(
                               switch (Topic.creatorName(topic)) {
                               | Some(name) => name ++ " "
                               | None => "Unknown "
                               }
                             )
                             |> str}
                          </span>
                          <span className="hidden md:inline-block md:mr-2">
                            {"on " ++ Topic.time(topic) |> str}
                          </span>
                          <span
                            className="block md:inline-block mt-1 md:mt-0 md:px-2 bg-gray-100 md:border-l border-gray-400">
                            {switch (Topic.lastActivityAt(topic)) {
                             | Some(time) =>
                               <span>
                                 <span className="hidden md:inline-block">
                                   {"updated" |> str}
                                 </span>
                                 <i
                                   className="fas fa-history mr-1 md:hidden"
                                 />
                                 {" " ++ time ++ " " |> str}
                                 <span> {"ago" |> str} </span>
                               </span>
                             | None => React.null
                             }}
                          </span>
                        </span>
                      </span>
                      <span className="flex flex-row ml-2">
                        <span className="px-4 text-center" ariaLabel="Likes">
                          <i
                            className="far fa-thumbs-up text-xl text-gray-600"
                          />
                          <p className="text-xs pt-1">
                            {Topic.likesCount(topic) |> string_of_int |> str}
                          </p>
                        </span>
                        <span className="px-2 text-center" ariaLabel="Replies">
                          <i
                            className="far fa-comment-dots text-xl text-gray-600"
                          />
                          <p className="text-xs pt-1">
                            {Topic.liveRepliesCount(topic)
                             |> string_of_int
                             |> str}
                          </p>
                        </span>
                      </span>
                    </a>
                  </div>
                </div>
              )
           |> React.array}
          {topics |> ArrayUtils.isEmpty
             ? <div
                 className="flex flex-col mx-auto bg-white p-6 justify-center items-center">
                 <i className="fas fa-comments text-5xl text-gray-400" />
                 <h4 className="mt-3 font-semibold">
                   {"There's no discussion here yet." |> str}
                 </h4>
               </div>
             : React.null}
        </div>
      </div>
    </div>
    <div
      className="max-w-3xl w-full flex flex-row mx-auto justify-center pb-8">
      {showPrevPage
         ? <a
             className="block btn btn-default no-underline border shadow mx-2"
             href="prev_page_path">
             <i className="fas fa-arrow-left" />
             <span className="ml-2"> {"Prev" |> str} </span>
           </a>
         : React.null}
      {showNextPage
         ? <a
             className="block btn btn-default no-underline border shadow mx-2"
             href="next_page_path">
             <span className="mr-2"> {"Next" |> str} </span>
             <i className="fas fa-arrow-right" />
           </a>
         : React.null}
    </div>
  </div>;
};
