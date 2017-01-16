class TimelineBuilderFacebookShareToggleButton extends React.Component {
  constructor(props) {
    super(props);
    this.showPopover = this.showPopover.bind(this);
  }

  componentDidMount() {
    if (this.props.disabled) {
      $('.timeline-builder__social-bar-toggle-switch').popover({
        title: 'Facebook Connect Missing!',
        content: 'Please <a href="/founder/edit">connect your profile to Facebook</a> first to use this feature.',
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
    if (this.props.disabled) {
      $('.timeline-builder__social-bar-toggle-switch').popover('show');

      setTimeout(function () {
        $('.timeline-builder__social-bar-toggle-switch').popover('hide');
      }, 4000);
    }
  }

  render() {
    return (
      <label className="timeline-builder__social-bar-toggle-switch" onClick={ this.showPopover }>
        <input type="checkbox" className="timeline-builder__social-bar-toggle-switch-input"
               disabled={ this.props.disabled }/>
        <span className="timeline-builder__social-bar-toggle-switch-label" data-on="SHARE" data-off="SHARE"/>
        <span className="timeline-builder__social-bar-toggle-switch-handle">
            <i className="fa fa-facebook"/>
          </span>
      </label>
    );
  }
}

TimelineBuilderFacebookShareToggleButton.propTypes = {
  disabled: React.PropTypes.bool
};
