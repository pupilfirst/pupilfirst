open TopicsShow__Types;

let str = React.string;

[@bs.val] external currentTime: unit => string = "Date.now";

module CreatePostQuery = [%graphql
  {|
  mutation CreatePostMutation($body: String!, $topicId: ID!, $replyToPostId: ID) {
    createPost(body: $body, topicId: $topicId, replyToPostId: $replyToPostId)  {
      postId
    }
  }
|}
];

module UpdatePostQuery = [%graphql
  {|
  mutation UpdatePostMutation($id: ID!, $body: String!) {
    updatePost(id: $id, body: $body)  {
      success
    }
  }
|}
];

let dateTime = currentTime() |> DateFns.parseString;

let handlePostCreateCB =
    (
      id,
      body,
      postNumber,
      currentUserId,
      setBody,
      setSaving,
      handleCloseCB,
      handlePostCB,
    ) => {
  let post =
    Post.make(
      id,
      body,
      currentUserId,
      None,
      postNumber,
      dateTime,
      dateTime,
      [||],
      [||],
      false,
    );
  setBody(_ => "");
  setSaving(_ => false);
  handleCloseCB |> OptionUtils.mapWithDefault(cb => cb(), ());
  handlePostCB(post);
};

let handlePostUpdateResponseCB =
    (
      id,
      body,
      currentUserId,
      setBody,
      setSaving,
      handleCloseCB,
      handlePostCB,
      post,
    ) => {
  let updatedPost =
    Post.make(
      id,
      body,
      post |> Post.creatorId,
      Some(currentUserId),
      post |> Post.postNumber,
      post |> Post.createdAt,
      dateTime,
      post |> Post.postLikes,
      post |> Post.replies,
      post |> Post.solution,
    );
  setBody(_ => "");
  setSaving(_ => false);
  handleCloseCB |> OptionUtils.mapWithDefault(cb => cb(), ());
  handlePostCB(updatedPost);
};

let savePost =
    (
      body,
      topic,
      setSaving,
      currentUserId,
      replyToPostId,
      setBody,
      handlePostCB,
      post,
      postNumber,
      handleCloseCB,
      event,
    ) => {
  event |> ReactEvent.Mouse.preventDefault;
  if (body != "") {
    setSaving(_ => true);

    switch (post) {
    | Some(post) =>
      let postId = post |> Post.id;

      UpdatePostQuery.make(~id=postId, ~body, ())
      |> GraphqlQuery.sendQuery
      |> Js.Promise.then_(response => {
           response##updatePost##success
             ? handlePostUpdateResponseCB(
                 postId,
                 body,
                 currentUserId,
                 setBody,
                 setSaving,
                 handleCloseCB,
                 handlePostCB,
                 post,
               )
             : setSaving(_ => false);
           Js.Promise.resolve();
         })
      |> Js.Promise.catch(_ => {
           setSaving(_ => false);
           Js.Promise.resolve();
         })
      |> ignore;
    | None =>
      CreatePostQuery.make(
        ~body,
        ~topicId=topic |> Topic.id,
        ~replyToPostId?,
        (),
      )
      |> GraphqlQuery.sendQuery
      |> Js.Promise.then_(response => {
           switch (response##createPost##postId) {
           | Some(postId) =>
             handlePostCreateCB(
               postId,
               body,
               postNumber,
               currentUserId,
               setBody,
               setSaving,
               handleCloseCB,
               handlePostCB,
             )
           | None => setSaving(_ => false)
           };
           Js.Promise.resolve();
         })
      |> Js.Promise.catch(_ => {
           setSaving(_ => false);
           Js.Promise.resolve();
         })
      |> ignore
    };
  } else {
    Notification.error("Empty", "Answer cant be blank");
  };
};

let onBorderAnimationEnd = event => {
  let element =
    ReactEvent.Animation.target(event) |> DomUtils.EventTarget.unsafeToElement;
  element->Webapi.Dom.Element.setClassName("");
};

[@react.component]
let make =
    (
      ~id,
      ~topic,
      ~currentUserId,
      ~postNumber,
      ~handlePostCB,
      ~replyToPostId=?,
      ~post=?,
      ~handleCloseCB=?,
    ) => {
  let (body, setBody) =
    React.useState(() =>
      switch (post) {
      | Some(post) => post |> Post.body
      | None => ""
      }
    );
  let (saving, setSaving) = React.useState(() => false);
  let updateMarkdownCB = body => setBody(_ => body);
  <DisablingCover disabled=saving>
    <div
      className="py-2 max-w-4xl w-full flex mx-auto items-center justify-center relative">
      <div className="flex w-full">
        <div className="w-full flex flex-col">
          <label
            className="inline-block tracking-wide text-gray-900 text-sm font-semibold mb-2"
            htmlFor="new-answer">
            {"Your Reply" |> str}
          </label>
          <div
            className="max-w-md rounded border border-primary-200 p-3 bg-gray-200 mb-3">
            <div className="flex justify-between">
              <div className="flex items-center border bg-white p-1 rounded">
                <span className="text-xs font-semibold ml-2">
                  {"User Name" |> str}
                </span>
              </div>
              <div
                className="flex w-6 h-6 p-2 items-center justify-center cursor-pointer border border-gray-400 rounded bg-gray-200 hover:bg-gray-400">
                <PfIcon className="if i-times-regular text-base" />
              </div>
            </div>
            <p className="text-sm pt-2 max-w-sm truncate">
              {"Similique sapiente non. Et consequatur. Maiores enim fugit..."
               |> str}
            </p>
          </div>
          <div id onAnimationEnd=onBorderAnimationEnd>
            <MarkdownEditor
              placeholder="Type in your answer. You can use Markdown to format your response."
              textareaId="new-answer"
              onChange=updateMarkdownCB
              value=body
              profile=Markdown.QuestionAndAnswer
              maxLength=10000
            />
          </div>
          <div className="flex justify-end pt-3">
            {switch (handleCloseCB) {
             | Some(handleCloseCB) =>
               <button
                 disabled=saving
                 onClick={_ => handleCloseCB()}
                 className="btn btn-subtle mr-2">
                 {"Cancel" |> str}
               </button>
             | None => React.null
             }}
            <button
              disabled={saving || body == ""}
              onClick={savePost(
                body,
                topic,
                setSaving,
                currentUserId,
                replyToPostId,
                setBody,
                handlePostCB,
                post,
                postNumber,
                handleCloseCB,
              )}
              className="btn btn-primary">
              {(
                 switch (post) {
                 | Some(_) => "Update Your Reply"
                 | None => "Post Your Reply"
                 }
               )
               |> str}
            </button>
          </div>
        </div>
      </div>
    </div>
  </DisablingCover>;
};
