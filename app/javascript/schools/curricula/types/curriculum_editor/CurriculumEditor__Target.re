type t = {
  id: int,
  targetGroupId: int,
  title: string,
  description: string,
  videoEmbed: option(string),
  slideshowEmbed: option(string),
  evaluationCriteria: list(int),
  prerequisiteTargets: list(int),
  quiz: list(CurriculumEditor__QuizQuestion.t),
  resources: list(CurriculumEditor__Resource.t),
  linkToComplete: option(string),
  role: string,
  targetActionType: string,
  sortIndex: int,
};

let id = t => t.id;

let title = t => t.title;

let targetGroupId = t => t.targetGroupId;

let description = t => t.description;

let videoEmbed = t => t.videoEmbed;

let slideshowEmbed = t => t.slideshowEmbed;

let evaluationCriteria = t => t.evaluationCriteria;

let prerequisiteTargets = t => t.prerequisiteTargets;

let quiz = t => t.quiz;

let resources = t => t.resources;

let linkToComplete = t => t.linkToComplete;

let role = t => t.role;

let targetActionType = t => t.targetActionType;

let sortIndex = t => t.sortIndex;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    targetGroupId: json |> field("targetGroupId", int),
    title: json |> field("title", string),
    description: json |> field("description", string),
    videoEmbed:
      json |> field("videoEmbed", nullable(string)) |> Js.Null.toOption,
    slideshowEmbed:
      json |> field("slideshowEmbed", nullable(string)) |> Js.Null.toOption,
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
      videoEmbed,
      slideshowEmbed,
      evaluationCriteria,
      prerequisiteTargets,
      quiz,
      resources,
      linkToComplete,
      role,
      targetActionType,
      sortIndex,
    ) => {
  id,
  targetGroupId,
  title,
  description,
  videoEmbed,
  slideshowEmbed,
  evaluationCriteria,
  prerequisiteTargets,
  quiz,
  resources,
  linkToComplete,
  role,
  targetActionType,
  sortIndex,
};

let sort = targets =>
  targets |> List.sort((x, y) => x.sortIndex - y.sortIndex);