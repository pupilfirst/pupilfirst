class FounderDashboardTargetDescription extends React.Component {
  constructor(props) {
    super(props);
    this.state = {targetFeedback: {}};

    this.updateStartupFeedback = this.updateStartupFeedback.bind(this);
  }

  assigner() {
    if (typeof(this.props.target.assigner) === 'undefined' || this.props.target.assigner === null) {
      return null;
    } else {
      return (
        <h6 className="pull-sm-left assigner-name m-a-0">
          Assigned by&nbsp;
          <span className="font-regular">{ this.props.target.assigner.name }</span>
        </h6>
      );
    }
  }

  componentDidMount() {
    // Ugly ugly hack to handle the Read SV story target
    // Opens the SV story in a new tab and triggers a GA event
    let storyURL = 'https://drive.google.com/file/d/0B57vU-yugIcOazNWUlB0cGl6cVU/view';
    if (this.props.target.description.indexOf(storyURL) !== -1) {
      let link = $('a[href="' + storyURL + '"]')
      link.on('click', function(event) {
        event.preventDefault();
        window.open(storyURL);
        ga('send', 'event', 'Link', 'click', 'SV-Story');
      });
    }
  }

  componentWillReceiveProps(newProps) {
    if (newProps.fetchTargetFeedback && !this.props.fetchTargetFeedback) {
      // fetch the feedbacks for the most recent timeline_event for the target
      console.log('Fetching feedback for target submission');

      let that = this;
      $.ajax({
        url: '/targets/' + that.props.target.id + '/startup_feedback',
        success: that.updateStartupFeedback
      });
    }
  }

  updateStartupFeedback(response) {
    this.setState({targetFeedback: response});
  }

  render() {
    return (
      <div className="target-description">
        <div className="target-description-header clearfix m-b-1">
          { this.assigner() }
        </div>

        <h6 className="founder-dashboard-target-header__headline--sm hidden-md-up">
          { this.props.target.title }
        </h6>

        <p className="target-description-content font-light" dangerouslySetInnerHTML={{__html: this.props.target.description}}/>
        <p className="target-description-content font-light" dangerouslySetInnerHTML={{__html: this.props.target.description}}/>


        { this.props.target.role === 'founder' && <FounderDashboardFounderStatusPanel founderDetails={ this.props.founderDetails } targetId={ this.props.target.id} fetchStatus={this.props.fetchFounderStatuses}/> }

        <FounderDashboardResourcesBar target={ this.props.target }/>

        <FounderDashboardSubmissionPanel target={ this.props.target }
          openTimelineBuilderCB={ this.props.openTimelineBuilderCB }
          fetchTargetPrerequisite={ this.props.fetchTargetPrerequisite}/>
      </div>
    );
  }
}

FounderDashboardTargetDescription.propTypes = {
  target: React.PropTypes.object,
  openTimelineBuilderCB: React.PropTypes.func,
  founderDetails: React.PropTypes.array,
  fetchFounderStatuses: React.PropTypes.bool,
  fetchTargetPrerequisite: React.PropTypes.bool,
  fetchTargetFeedback: React.PropTypes.bool
};
