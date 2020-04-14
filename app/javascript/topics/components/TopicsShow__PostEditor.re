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
    (id, body, postNumber, currentUserId, setBody, setSaving, handlePostCB) => {
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
  handlePostCB(post);
};

let handlePostUpdateResponseCB =
    (id, body, currentUserId, setBody, setSaving, handlePostCB, post) => {
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
               handlePostCB,
             );
             setSaving(_ => false);
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
  switch (handleCloseCB) {
  | Some(cb) => cb()
  | None => ()
  };
};

[@react.component]
let make =
    (
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
            className="inline-block tracking-wide text-gray-900 text-sm font-bold mb-2"
            htmlFor="new-answer">
            {"Your Reply" |> str}
          </label>
          <MarkdownEditor
            placeholder="Type in your answer. You can use Markdown to format your response."
            textareaId="new-answer"
            onChange=updateMarkdownCB
            value=body
            profile=Markdown.QuestionAndAnswer
            maxLength=10000
          />
          <div className="flex justify-end pt-3 border-t">
            {switch (handleCloseCB) {
             | Some(handleCloseCB) =>
               <button
                 disabled=saving
                 onClick={_ => handleCloseCB()}
                 className="btn btn-default mr-2">
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
