[%bs.raw {|require("./TimelineEventCard.scss")|}];

let str = ReasonReact.string;

let component = ReasonReact.statelessComponent("TimelineEventCard");

let make = (~timelineEvent, ~replaceTE_CB, ~authenticityToken, _children) => {
  ...component,
  render: _self =>
    <div className="timeline-event-card__container card">
      <div className="card-header d-flex">
        <div>
          (timelineEvent |> TimelineEvent.title |> str)
          <div className="timeline-event-card__header-subtext">
            (
              (timelineEvent |> TimelineEvent.founderName)
              ++ " ("
              ++ (timelineEvent |> TimelineEvent.startupName)
              ++ ")"
              |> str
            )
          </div>
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
      <div className="card-body row">
        <div className="col-md-7">
          <h5 className="timeline-event-card__field-header mt-0">
            ("Description:" |> str)
          </h5>
          (timelineEvent |> TimelineEvent.description |> str)
          <FeedbackForm />
        </div>
        <div className="col-md-5">
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
                       className="btn btn-secondary mr-1"
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
                       className="btn btn-secondary mr-1"
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