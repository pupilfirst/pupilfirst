class TimelineBuilderSocialBar extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return(
      <div className="timeline-builder__social-bar clearfix">
        <TimelineBuilderFacebookShareToggleButton disabled={ !this.props.allowFacebookShare }/>
        <TimelineBuilderTextAreaCounter description={ this.props.description } />
      </div>
    );
  }
}

TimelineBuilderSocialBar.propTypes = {
  description: React.PropTypes.string,
  allowFacebookShare: React.PropTypes.bool
};
