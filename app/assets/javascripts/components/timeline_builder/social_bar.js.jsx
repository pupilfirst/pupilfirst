class TimelineBuilderSocialBar extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return(
      <div className="timeline-builder__social-bar">
        { this.props.showFacebookToggle &&
        <TimelineBuilderFacebookShareToggleButton />
        }
        <TimelineBuilderTextAreaCounter description={ this.props.description } />
      </div>
    );
  }
}

TimelineBuilderSocialBar.propTypes = {
  description: React.PropTypes.string,
  showFacebookToggle: React.PropTypes.bool
};
