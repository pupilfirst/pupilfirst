class TimelineBuilderEventTypeSelect extends React.Component {
  constructor(props) {
    super(props);

    this.handleTimelineEventTypeChange = this.handleTimelineEventTypeChange.bind(this);
  }

  componentDidMount() {
    let timelineEventTypeSelect = $('.js-timeline-builder__timeline-event-type-select');
    timelineEventTypeSelect.select2({placeholder: "Select Type of Event"});
    timelineEventTypeSelect.on('change', this.handleTimelineEventTypeChange);
  }

  componentDidUpdate() {
    let status = this.props.showEventTypeError ? 'show' : 'hide';
    $('.js-timeline-builder__timeline-event-type-select-wrapper').popover(status);
  }

  handleTimelineEventTypeChange(event) {
    this.props.resetErrorsCB();

    let timelineEventTypeSelect = $(event.target);

    if (timelineEventTypeSelect.val().length > 0) {
      let newTimelineEventTypeId = parseInt(timelineEventTypeSelect.val());
      this.props.addDataCB('timeline_event_type', {id: parseInt(newTimelineEventTypeId)});
    }
  }

  wrapperClasses() {
    return (
      "timeline-builder__select-section-tab" +
      " timeline-builder__timeline-event-type-select-wrapper" +
      " js-timeline-builder__timeline-event-type-select-wrapper"
    )
  }

  render() {
    return (
      <div className={ this.wrapperClasses() } data-toggle="popover" data-title="Type Missing!" data-trigger="manual"
           data-content="Please select an appropriate timeline event type." data-placement="bottom">
        <select className="form-control js-timeline-builder__timeline-event-type-select"
                defaultValue={ this.props.timelineEventTypeId }>
          <option/>
          { Object.keys(this.props.timelineEventTypes).map(function (role, index) {
            return <TimelineBuilderTimelineEventGroup key={ index } role={ role }
                                                      timelineEvents={ this.props.timelineEventTypes[role] }/>
          }, this)}
        </select>
      </div>
    );
  }
}

TimelineBuilderEventTypeSelect.propTypes = {
  selectedDate: React.PropTypes.string,
  resetErrorsCB: React.PropTypes.func,
  timelineEventTypeId: React.PropTypes.string,
  timelineEventTypes: React.PropTypes.object,
  showEventTypeError: React.PropTypes.bool
};
