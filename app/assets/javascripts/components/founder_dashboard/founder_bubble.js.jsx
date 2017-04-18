class FounderDashboardFounderBubble extends React.Component {
  constructor(props) {
    super(props);
    this.showTooltip = this.showTooltip.bind(this);
  }

  statusIcon() {
    if (this.props.status === 'complete') {
      return 'fa fa-check-circle brand-primary';
    } else if ( this.props.status === 'loading') {
      return 'fa fa-refresh fa-spin brand-primary';
    } else {
      return 'fa fa-exclamation-circle alert-background';
    }
  }

  statusDescription() {
    let name = this.props.name;
    let status = this.props.status;
    if (status === 'loading') {
      return 'Fetching target status for ' + name + '.';
    } else if (status === 'complete') {
      return name + ' has completed this target.';
    } else {
      return name + ' is yet to complete this target!';
    }
  }

  showTooltip(event) {
    let element = $(event.target.closest('a'));
    element.tooltip({title: this.statusDescription()});
  }

  hideTooltip(event) {
    let element = $(event.target.closest('a'));
    element.tooltip('dispose');
  }

  render() {
    return (
      <a className="founder-avatar-bubble" onMouseEnter={this.showTooltip} onMouseLeave={this.hideTooltip}>
        <div className="target-complete-check img-circle">
          <i className={this.statusIcon()}/>
        </div>
        <img className="img-circle" src={this.props.url}/>
      </a>
    );
  }
}

FounderDashboardFounderBubble.propTypes = {
  name: React.PropTypes.string,
  url: React.PropTypes.string,
  status: React.PropTypes.string
};
