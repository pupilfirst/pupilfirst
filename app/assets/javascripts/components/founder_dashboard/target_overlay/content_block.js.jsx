class TargetOverlayContentBlock extends React.Component {
  constructor(props) {
    super(props);
    this.state = {targetFeedback: {}};

    this.updateStartupFeedback = this.updateStartupFeedback.bind(this);
  }

  componentDidMount() {
    // Ugly ugly hack to handle the Read SV story target
    // Opens the SV story in a new tab and triggers a GA event
    let storyURL = 'https://drive.google.com/file/d/0B57vU-yugIcOazNWUlB0cGl6cVU/view';

    if (this.props.target.description.indexOf(storyURL) !== -1) {
      let link = $('a[href="' + storyURL + '"]');

      link.on('click', function (event) {
        event.preventDefault();
        window.open(storyURL);
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
      <div className="target-overlay-content-block">
        <div className="target-overlay-content-block__header p-b-1 clearfix">
          <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.targetDescription }/>
          <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Target Description</h5>
        </div>
        <div className="target-overlay-content-block__description p-b-1">
          <p className="font-light" dangerouslySetInnerHTML={{__html: this.props.target.description}}/>
        </div>

        <div className="target-overlay-content-block__header p-b-1 clearfix">
          <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.slideshowEmbed }/>
          <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Presentation</h5>
        </div>
        <div className= "target-overlay-content-block__embed-block p-b-1">
          <div dangerouslySetInnerHTML={ { __html: this.props.target.slideshow_embed } }></div>
        </div>

        <div className="target-overlay-content-block__header p-b-1 clearfix">
          <img className="target-overlay-content-block__header-icon pull-xs-left" src={ this.props.iconPaths.videoEmbed }/>
          <h5 className="target-overlay-content-block__header m-a-0 pull-xs-left font-semibold">Video</h5>
        </div>
        <div className= "target-overlay-content-block__embed-block p-b-1">
          <div dangerouslySetInnerHTML={ { __html: this.props.target.video_embed } }></div>
        </div>
      </div>
    );
  }
}

TargetOverlayContentBlock.propTypes = {
  target: React.PropTypes.object,
  openTimelineBuilderCB: React.PropTypes.func,
  iconPaths: React.PropTypes.object,
  founderDetails: React.PropTypes.array,
  fetchFounderStatuses: React.PropTypes.bool,
  fetchTargetPrerequisite: React.PropTypes.bool,
  fetchTargetFeedback: React.PropTypes.bool
};
