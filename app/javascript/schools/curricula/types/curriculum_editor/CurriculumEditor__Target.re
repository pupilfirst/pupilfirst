exception InvalidVisibilityValue(string);

type t = {
  id: int,
  targetGroupId: int,
  title: string,
  evaluationCriteria: list(int),
  prerequisiteTargets: list(int),
  quiz: list(CurriculumEditor__QuizQuestion.t),
  linkToComplete: option(string),
  sortIndex: int,
  visibility: string,
};

let id = t => t.id;

let title = t => t.title;

let targetGroupId = t => t.targetGroupId;

let evaluationCriteria = t => t.evaluationCriteria;

let prerequisiteTargets = t => t.prerequisiteTargets;

let quiz = t => t.quiz;

let linkToComplete = t => t.linkToComplete;

let sortIndex = t => t.sortIndex;

let visibility = t => t.visibility;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    targetGroupId: json |> field("targetGroupId", int),
    title: json |> field("title", string),
    evaluationCriteria: json |> field("evaluationCriteria", list(int)),
    prerequisiteTargets: json |> field("prerequisiteTargets", list(int)),
    quiz: json |> field("quiz", list(CurriculumEditor__QuizQuestion.decode)),
    linkToComplete:
      json |> field("linkToComplete", nullable(string)) |> Js.Null.toOption,
    sortIndex: json |> field("sortIndex", int),
    visibility: json |> field("visibility", string),
  };

let decodeVisibility = visibilityString =>
  switch (visibilityString) {
  | unknownValue => raise(InvalidVisibilityValue(unknownValue))
  };

let updateList = (targets, target) => {
  let oldTargets = targets |> List.filter(t => t.id !== target.id);
  oldTargets |> List.rev |> List.append([target]) |> List.rev;
};

let create =
    (
      id,
      targetGroupId,
      title,
      evaluationCriteria,
      prerequisiteTargets,
      quiz,
      linkToComplete,
      sortIndex,
      visibility,
    ) => {
  id,
  targetGroupId,
  title,
  evaluationCriteria,
  prerequisiteTargets,
  quiz,
  linkToComplete,
  sortIndex,
  visibility,
};

let sort = targets =>
  targets |> List.sort((x, y) => x.sortIndex - y.sortIndex);

let archive = t => {...t, visibility: "archived"};

let find = (id, targets) => targets |> List.find(t => t.id == id);

let removeTarget = (target, targets) =>
  targets |> List.filter(t => t.id != target.id);

let targetIdsInTargetGroup = (id, targets) =>
  targets |> List.filter(t => t.targetGroupId == id) |> List.map(t => t.id);