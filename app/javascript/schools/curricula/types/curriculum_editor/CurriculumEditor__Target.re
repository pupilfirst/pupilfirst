type t = {
  id: int,
  targetGroupId: int,
  title: string,
  description: string,
  youtubeVideoId: option(string),
  evaluationCriteria: list(int),
  prerequisiteTargets: list(int),
  quiz: list(CurriculumEditor__QuizQuestion.t),
  resources: list(CurriculumEditor__Resource.t),
  linkToComplete: option(string),
  role: string,
  targetActionType: string,
  sortIndex: int,
  archived: bool,
};

let id = t => t.id;

let title = t => t.title;

let targetGroupId = t => t.targetGroupId;

let description = t => t.description;

let youtubeVideoId = t => t.youtubeVideoId;

let evaluationCriteria = t => t.evaluationCriteria;

let prerequisiteTargets = t => t.prerequisiteTargets;

let quiz = t => t.quiz;

let resources = t => t.resources;

let linkToComplete = t => t.linkToComplete;

let role = t => t.role;

let targetActionType = t => t.targetActionType;

let sortIndex = t => t.sortIndex;

let archived = t => t.archived;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    targetGroupId: json |> field("targetGroupId", int),
    title: json |> field("title", string),
    description: json |> field("description", string),
    youtubeVideoId:
      json |> field("youtubeVideoId", nullable(string)) |> Js.Null.toOption,
    evaluationCriteria: json |> field("evaluationCriteria", list(int)),
    prerequisiteTargets: json |> field("prerequisiteTargets", list(int)),
    quiz: json |> field("quiz", list(CurriculumEditor__QuizQuestion.decode)),
    resources:
      json |> field("resources", list(CurriculumEditor__Resource.decode)),
    linkToComplete:
      json |> field("linkToComplete", nullable(string)) |> Js.Null.toOption,
    role: json |> field("role", string),
    targetActionType: json |> field("targetActionType", string),
    sortIndex: json |> field("sortIndex", int),
    archived: json |> field("archived", bool),
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
      description,
      youtubeVideoId,
      evaluationCriteria,
      prerequisiteTargets,
      quiz,
      resources,
      linkToComplete,
      role,
      targetActionType,
      sortIndex,
      archived,
    ) => {
  id,
  targetGroupId,
  title,
  description,
  youtubeVideoId,
  evaluationCriteria,
  prerequisiteTargets,
  quiz,
  resources,
  linkToComplete,
  role,
  targetActionType,
  sortIndex,
  archived,
};

let sort = targets =>
  targets |> List.sort((x, y) => x.sortIndex - y.sortIndex);

let archive = (t, archived) => {...t, archived};

let find = (id, targets) => targets |> List.find(t => t.id == id);

let removeTarget = (target, targets) =>
  targets |> List.filter(t => t.id != target.id);

let targetIdsInTargetGroup = (id, targets) =>
  targets |> List.filter(t => t.targetGroupId == id) |> List.map(t => t.id);