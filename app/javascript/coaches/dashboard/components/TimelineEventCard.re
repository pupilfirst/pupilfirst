[%bs.raw {|require("./TimelineEventCard.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventCard");

let teImage = timelineEvent =>
  switch (timelineEvent |> TimelineEvent.image) {
  | None => ReasonReact.null
  | Some(url) =>
    <div>
      <a
        href=url
        target="_blank"
        className="badge badge-secondary font-regular mr-2">
        <i className="fa fa-file-image-o mr-1" />
        ("Cover Image" |> str)
      </a>
    </div>
  };

let teLinks = timelineEvent =>
  switch (timelineEvent |> TimelineEvent.links) {
  | [] => ReasonReact.null
  | links =>
    <div>
      (
        links
        |> List.map(link =>
             <a
               href=(link |> Link.url)
               target="_blank"
               className="badge badge-secondary font-regular mr-2"
               key=(link |> Link.url)>
               (
                 link |> Link.private ?
                   <i className="fa fa-lock mr-1" /> :
                   <i className="fa fa-globe mr-1" />
               )
               (link |> Link.title |> str)
             </a>
           )
        |> Array.of_list
        |> ReasonReact.array
      )
    </div>
  };

let teFiles = timelineEvent =>
  switch (timelineEvent |> TimelineEvent.files) {
  | [] => ReasonReact.null
  | files =>
    <div>
      (
        files
        |> List.map(file => {
             let id = file |> File.id |> string_of_int;
             let url = "/timeline_event_files/" ++ id ++ "/download";
             <a
               href=url
               target="_blank"
               className="badge badge-secondary font-regular mr-2"
               key=id>
               <i className="fa fa-file mr-1" />
               (file |> File.title |> str)
             </a>;
           })
        |> Array.of_list
        |> ReasonReact.array
      )
    </div>
  };

let attachmentsSection = timelineEvent => {
  let links = timelineEvent |> TimelineEvent.links;
  let files = timelineEvent |> TimelineEvent.files;
  let image = timelineEvent |> TimelineEvent.image;
  switch (links |> List.length, files |> List.length, image) {
  | (0, 0, None) => ReasonReact.null
  | _ =>
    <div className="timeline-event-card__field-attachments">
      <h5
        className="timeline-event-card__field-attachments-title mt-3 mb-1 font-regular">
        ("Attachments:" |> str)
      </h5>
      <div className="d-flex">
        (timelineEvent |> teImage)
        (timelineEvent |> teLinks)
        (timelineEvent |> teFiles)
      </div>
    </div>
  };
};

let make =
    (
      ~timelineEvent,
      ~replaceTimelineEvent,
      ~authenticityToken,
      ~needsImprovementIconUrl,
      ~notAcceptedIconUrl,
      ~verifiedIconUrl,
      ~gradeLabels,
      ~passGrade,
      _children,
    ) => {
  ...component,
  render: _self =>
    <div className="timeline-event-card__container">
      <div className="timeline-event-card__body row">
        <div
          className="timeline-event-card__header d-flex align-items-center w-100 p-3">
          <div>
            <h5
              className="timeline-event-card__header-title font-semibold mb-1">
              (timelineEvent |> TimelineEvent.title |> str)
            </h5>
            <h6
              className="timeline-event-card__header-subtext font-regular mb-0">
              (
                (timelineEvent |> TimelineEvent.founderName)
                ++ " ("
                ++ (timelineEvent |> TimelineEvent.startupName)
                ++ ")"
                |> str
              )
              <span
                className="timeline-event-card__header-date-field pl-2 ml-2">
                <i className="fa fa-calendar mr-1" />
                (
                  timelineEvent
                  |> TimelineEvent.eventOn
                  |> DateTime.format(DateTime.OnlyDate)
                  |> str
                )
              </span>
            </h6>
          </div>
        </div>
        <div className="col-md-6 timeline-event-card__field-container py-3">
          <h5
            className="timeline-event-card__field-header font-semibold mt-0 mb-3">
            ("Description:" |> str)
          </h5>
          <div className="timeline-event-card__field-box pl-3">
            <div className="timeline-event-card__description">
              (timelineEvent |> TimelineEvent.description |> str)
            </div>
            (timelineEvent |> attachmentsSection)
          </div>
        </div>
        <div
          className=(
            "col-md-6 d-flex flex-column align-items-center timeline-event-card__review-box js-timeline-event-card__review-box-"
            ++ (timelineEvent |> TimelineEvent.id |> string_of_int)
          )>
          (
            timelineEvent |> TimelineEvent.evaluation |> Grading.pending ?
              <EvaluationForm
                timelineEvent
                gradeLabels
                replaceTimelineEvent
                authenticityToken
                passGrade
              /> :
              <div className="mx-auto text-center">
                <ReviewStatusBadge
                  reviewResult=(
                    timelineEvent |> TimelineEvent.getReviewResult(4)
                  )
                  notAcceptedIconUrl
                  verifiedIconUrl
                />
                {
                  let evaluation = timelineEvent |> TimelineEvent.evaluation;
                  evaluation
                  |> List.map(grading =>
                       <GradeBar
                         key=(grading |> Grading.criterionId |> string_of_int)
                         grading
                         gradeLabels
                         passGrade
                       />
                     )
                  |> Array.of_list
                  |> ReasonReact.array;
                }
                <UndoReviewButton timelineEvent replaceTimelineEvent />
              </div>
          )
          <FeedbackForm timelineEvent replaceTimelineEvent authenticityToken />
        </div>
      </div>
    </div>,
};