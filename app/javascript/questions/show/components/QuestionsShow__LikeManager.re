[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

module CreateAnswerLikeQuery = [%graphql
  {|
  mutation($answerId: ID!) {
    createAnswerLike(answerId: $answerId) @bsVariant {
      answerLikeId
      errors
    }
  }
|}
];

module DestroyAnswerLikeQuery = [%graphql
  {|
  mutation($id: ID!) {
    destroyAnswerLike(id: $id) {
      success
    }
  }
  |}
];

module CreateAnswerLikeError = {
  type t = [ | `LikeExist | `BlankAnswerId];

  let notification = error =>
    switch (error) {
    | `LikeExist => ("LikeExist", "You have already liked the answer!")
    | `BlankAnswerId => (
        "BlankAnswerId",
        "Answer id is required for adding a like",
      )
    };
};

module CreateAnswerLikeErrorHandler =
  GraphqlErrorHandler.Make(CreateAnswerLikeError);

let iconClasses = (liked, saving) => {
  let classes = "text-xl text-gray-600";
  classes
  ++ (
    if (saving) {
      " fas fa-spinner-third fa-spin";
    } else if (liked) {
      " fas fa-thumbs-up cursor-pointer text-yellow";
    } else {
      " fal fa-thumbs-up cursor-pointer";
    }
  );
};

[@react.component]
let make =
    (
      ~authenticityToken,
      ~likes,
      ~answerId,
      ~currentUserId,
      ~addLikeCB,
      ~removeLikeCB,
    ) => {
  let liked = likes |> Like.currentUserLiked(answerId, currentUserId);
  let (saving, setSaving) = React.useState(() => false);

  let handleCreateResponse = id => {
    let like = Like.create(id, currentUserId, answerId);
    setSaving(_ => false);
    addLikeCB(like);
  };
  let handleAnswerLike = event => {
    event |> ReactEvent.Mouse.preventDefault;
    setSaving(_ => true);
    if (liked) {
      let id =
        Like.likeByCurrentUser(answerId, currentUserId, likes)
        |> List.hd
        |> Like.id;
      DestroyAnswerLikeQuery.make(~id, ())
      |> GraphqlQuery.sendQuery(authenticityToken)
      |> Js.Promise.then_(_response => {
           removeLikeCB(id);
           setSaving(_ => false);
           Js.Promise.resolve();
         })
      |> ignore;
    } else {
      CreateAnswerLikeQuery.make(~answerId, ())
      |> GraphqlQuery.sendQuery(authenticityToken)
      |> Js.Promise.then_(response =>
           switch (response##createAnswerLike) {
           | `AnswerLikeId(answerLikeId) =>
             handleCreateResponse(answerLikeId);
             Js.Promise.resolve();
           | `Errors(errors) =>
             Js.Promise.reject(CreateAnswerLikeErrorHandler.Errors(errors))
           }
         )
      |> CreateAnswerLikeErrorHandler.catch(() => setSaving(_ => false))
      |> ignore;
    };
  };

  <div className="mr-2">
    <div className="pt-2 px-2 cursor-pointer" onClick=handleAnswerLike>
      <div key={iconClasses(liked, saving)}>
        <i className={iconClasses(liked, saving)} />
      </div>
      <p className="text-xs py-1">
        {
          likes
          |> Like.likesForAnswer(answerId)
          |> List.length
          |> string_of_int
          |> str
        }
      </p>
    </div>
  </div>;
};