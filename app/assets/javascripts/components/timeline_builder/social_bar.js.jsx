class TimelineBuilderSocialBar extends React.Component {
  render() {
    return(
      <div className="timeline-builder__social-bar">
        <label className="timeline-builder__social-bar-toggle-switch">
          <input type="checkbox" className="timeline-builder__social-bar-toggle-switch-input"/>
          <span className="timeline-builder__social-bar-toggle-switch-label" data-on="SHARED" data-off="SHARE"/>
          <span className="timeline-builder__social-bar-toggle-switch-handle">
            <i className="fa fa-facebook"/>
          </span>
        </label>
      </div>
    );
  }
}