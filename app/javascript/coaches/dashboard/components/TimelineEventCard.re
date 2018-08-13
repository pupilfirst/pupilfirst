[%bs.raw {|require("./TimelineEventCard.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventCard");

let make =
    (
      ~timelineEvent,
      ~replaceTimelineEvent,
      ~authenticityToken,
      ~needsImprovementIconUrl,
      ~notAcceptedIconUrl,
      ~verifiedIconUrl,
      _children,
    ) => {
  ...component,
  render: _self =>
    <div className="timeline-event-card__container">
      <div className="card-body row">
        <div className="col-md-8">
          <div
            className="timeline-event-card__header d-flex align-items-center pt-2 pb-2 mb-3">
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
          <div className="timeline-event-card__field-box p-3">
            <h5
              className="timeline-event-card__field-header font-semibold mt-0">
              ("Description:" |> str)
            </h5>
            (timelineEvent |> TimelineEvent.description |> str)
            {
              let links = timelineEvent |> TimelineEvent.links;
              let files = timelineEvent |> TimelineEvent.files;
              if (links |> List.length == 0 && files |> List.length == 0) {
                ReasonReact.null;
              } else {
                <div className="timeline-event-card__field-attachments">
                  <h5
                    className="timeline-event-card__field-attachments-title mt-3 mb-1 font-regular">
                    ("Attachments:" |> str)
                  </h5>
                  <div className="d-flex">
                    (
                      if (links |> List.length == 0) {
                        ReasonReact.null;
                      } else {
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
                        </div>;
                      }
                    )
                    (
                      if (files |> List.length == 0) {
                        ReasonReact.null;
                      } else {
                        <div>
                          (
                            files
                            |> List.map(file => {
                                 let id = file |> File.id |> string_of_int;
                                 let url =
                                   "/timeline_event_files/"
                                   ++ id
                                   ++ "/download";
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
                        </div>;
                      }
                    )
                  </div>
                </div>;
              };
            }
          </div>
          <FeedbackForm timelineEvent replaceTimelineEvent authenticityToken />
        </div>
        <div
          className=(
            "col-md-4 d-flex align-items-center timeline-event-card__review-box js-timeline-event-card__review-box-"
            ++ (timelineEvent |> TimelineEvent.id |> string_of_int)
          )>
          (
            switch (timelineEvent |> TimelineEvent.status) {
            | TimelineEvent.NotReviewed =>
              <ReviewForm
                key=(timelineEvent |> TimelineEvent.id |> string_of_int)
                timelineEvent
                replaceTimelineEvent
                authenticityToken
              />
            | Reviewed(reviewedStatus) =>
              <div className="mx-auto text-center">
                <ReviewStatusBadge
                  reviewedStatus
                  needsImprovementIconUrl
                  notAcceptedIconUrl
                  verifiedIconUrl
                />
                <UndoReviewButton timelineEvent replaceTimelineEvent />
              </div>
            }
          )
        </div>
      </div>
    </div>,
};