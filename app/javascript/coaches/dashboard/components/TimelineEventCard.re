[%bs.raw {|require("./TimelineEventCard.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventCard");

let make = (~timelineEvent, ~replaceTE_CB, ~authenticityToken, _children) => {
  ...component,
  render: _self =>
    <div className="timeline-event-card__container">
      <div className="card-body row">
        <div className="col-md-8">
          <div className="timeline-event-card__header d-flex align-items-center pt-2 pb-2 mb-3">
            <div>
              <h5 className="timeline-event-card__header-title font-semibold mb-1">
                (timelineEvent |> TimelineEvent.title |> str)
              </h5>
              <h6 className="timeline-event-card__header-subtext font-regular mb-0">
                (
                  (timelineEvent |> TimelineEvent.founderName)
                  ++ " ("
                  ++ (timelineEvent |> TimelineEvent.startupName)
                  ++ ")"
                  |> str
                )
              </h6>
            </div>
            <div className="ml-auto">
              <div className="timeline-event-card__header-date-field">
                <i className="fa fa-calendar mr-1" />
                (
                  timelineEvent
                  |> TimelineEvent.eventOn
                  |> DateTime.format(DateTime.OnlyDate)
                  |> str
                )
              </div>
            </div>
          </div>
          <div className="timeline-event-card__field-box p-3">
            <h5 className="timeline-event-card__field-header font-semibold mt-0">
              ("Description:" |> str)
            </h5>
            (timelineEvent |> TimelineEvent.description |> str)
            <div className="timeline-event-card__field-attachments">
              <h5 className="timeline-event-card__field-attachments-title mt-3 mb-1 font-regular">
                ("Attachments:" |> str)
              </h5>
              <div className="d-flex">
                {
                  let links = timelineEvent |> TimelineEvent.links;
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
                  };
                }
                {
                  let files = timelineEvent |> TimelineEvent.files;
                  if (files |> List.length == 0) {
                    ReasonReact.null;
                  } else {
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
                    </div>;
                  };
                }
              </div>
            </div>
          </div>
          <FeedbackForm timelineEvent authenticityToken />
        </div>
        <div className="col-md-4 d-flex align-items-center timeline-event-card__review-box">
          (
            switch (timelineEvent |> TimelineEvent.status) {
            | TimelineEvent.NotReviewed =>
              <ReviewForm
                key=(timelineEvent |> TimelineEvent.id |> string_of_int)
                timelineEvent
                replaceTE_CB
                authenticityToken
              />
            | Reviewed(_reviewedStatus) =>
              <UndoReviewButton timelineEvent replaceTE_CB />
            }
          )
        </div>
      </div>
      <div className="card-footer d-flex">
        <div className="ml-auto">
          (
            switch (timelineEvent |> TimelineEvent.status) {
            | TimelineEvent.NotReviewed =>
              <div className="timeline-event-card__footer-subtext">
                (
                  "Submitted at: "
                  ++ (
                    timelineEvent
                    |> TimelineEvent.submittedAt
                    |> DateTime.format(DateTime.DateAndTime)
                  )
                  |> str
                )
              </div>
            | Reviewed(reviewedStatus) => <ReviewStatusBadge reviewedStatus />
            }
          )
        </div>
      </div>
    </div>,
};