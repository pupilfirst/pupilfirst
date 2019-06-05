type t = {
  communityId: string,
  courseId: string,
};

let decode = json =>
  Json.Decode.{
    communityId: json |> field("communityId", string),
    courseId: json |> field("courseId", string),
  };

let communityId = t => t.communityId;

let courseId = t => t.courseId;

let create = (communityId, courseId) => {communityId, courseId};