class FounderDashboardTargetDescription extends React.Component {
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

  render() {
    return (
      <div className="target-description">
        <div className="target-description-header clearfix m-b-1">
          { this.assigner() }
        </div>

        <h6 className="founder-dashboard-target-header__headline--sm hidden-md-up">
          { this.props.target.title }
        </h6>

        <p className="target-description-content" dangerouslySetInnerHTML={{__html: this.props.target.description}}/>
        <FounderDashboardSubmissionPanel target={ this.props.target }/>
      </div>
    );
  }
}

FounderDashboardTargetDescription.propTypes = {
  target: React.PropTypes.object
};
