[@bs.config {jsx: 3}];
open QuestionsShow__Types;

/* type props = {name: int};

   let decodeProps = json =>
     Json.Decode.{
       authenticityToken: json |> field("authenticityToken", string),
     }; */

/* let decodeProps = json =>
   Json.Decode.{
     authenticityToken: json |> field("authenticityToken", string),
     question: json |> field("questions", Question.decode),
     answers: json |> field("answers", list(Answer.decode)),
     comments: json |> field("comments", list(Comment.decode)),
     userData: json |> field("userData", list(UserData.decode)),
     likes: json |> field("likes", list(Like.decode)),
     currentUserId: json |> field("currentUserId", string),
     communityPath: json |> field("communityPath", string),
   }; */

/* let props = DomUtils.parseJsonAttribute() |> decodeProps; */

ReactDOMRe.renderToElementWithId(<TopNav name="test" />, "nav-bar-props");
