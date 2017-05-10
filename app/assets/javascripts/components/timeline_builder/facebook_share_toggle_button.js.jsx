class TimelineBuilderFacebookShareToggleButton extends React.Component {
  constructor(props) {
    super(props);
    this.showPopover = this.showPopover.bind(this);
  }

  componentDidMount() {
    if (this.notEligible()) {
      $('.timeline-builder__social-bar-toggle-switch').popover({
        title: 'Feature Unavailable!',
        content: this.notEligibleMessage(),
        html: true,
        placement: 'bottom',
        trigger: 'manual'
      });
    }
  }

  componentWillUnmount() {
    $('.timeline-builder__social-bar-toggle-switch').popover('dispose');
  }

  showPopover() {
    if (this.notEligible()) {
      $('.timeline-builder__social-bar-toggle-switch').popover('show');

      setTimeout(function () {
        $('.timeline-builder__social-bar-toggle-switch').popover('hide');
      }, 4000);
    }
  }

  notEligible() {
    return this.props.facebookShareEligibility != 'eligible';
  }

  notEligibleMessage() {
    if (this.props.facebookShareEligibility == 'not_admitted') {
      return 'Facebook share is only available for founders above Level 0!';
    } else {
      return 'Please <a href="/founder/edit">connect your profile to Facebook</a> first to use this feature.';
    }
  }

  render() {
    return (
      <label className="timeline-builder__social-bar-toggle-switch" onClick={ this.showPopover }>
        <input type="checkbox" className="timeline-builder__social-bar-toggle-switch-input"
               disabled={ this.notEligible() }/>
        <span className="timeline-builder__social-bar-toggle-switch-label" data-on="SHARE" data-off="SHARE"/>
        <span className="timeline-builder__social-bar-toggle-switch-handle">
            <i className="fa fa-facebook"/>
          </span>
      </label>
    );
  }
}

TimelineBuilderFacebookShareToggleButton.propTypes = {
  facebookShareEligibility: React.PropTypes.string
};
