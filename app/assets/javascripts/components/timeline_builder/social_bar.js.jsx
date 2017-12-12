class TimelineBuilderSocialBar extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="timeline-builder__social-bar clearfix">
        <TimelineBuilderFacebookShareToggleButton
          facebookShareEligibility={this.props.facebookShareEligibility}
        />
        <TimelineBuilderTextAreaCounter description={this.props.description} />
      </div>
    );
  }
}

TimelineBuilderSocialBar.propTypes = {
  description: PropTypes.string,
  facebookShareEligibility: PropTypes.string
};
