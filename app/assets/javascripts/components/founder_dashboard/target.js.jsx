class FounderDashboardTarget extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      showDescription: false,
      fetchFounderStatuses: false,
      fetchTargetPrerequisite: false,
      fetchTargetFeedback: false
    };

    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    this.props.selectTargetCB(this.props.target.id, this.props.target.target_type);
  }

  animateDescription(open) {
    if (open) {
      if (!this.state.fetchFounderStatuses) {
        this.setState({fetchFounderStatuses: true});
      }
      if (this.props.target['status'] == 'complete' || this.props.target['status'] == 'needs_improvement' ||
        this.props.target['status'] == 'not_accepted' && !this.state.fetchTargetFeedback) {
        this.setState({fetchTargetFeedback: true});
      }
      if (this.props.target['status'] == 'unavailable' && !this.state.fetchTargetPrerequisite) {
        this.setState({fetchTargetPrerequisite: true});
      }
      $('#' + this.sliderId()).slideDown();
    } else {
      $('#' + this.sliderId()).slideUp();
    }
  }

  containerClasses() {
    let classes = 'founder-dashboard-target__container';

    if (this.state.showDescription) {
      classes += ' founder-dashboard-target__container--open';
    }

    return classes;
  }

  sliderId() {
    return 'founder-dashboard-target__description-container-' + this.props.target.id;
  }

  render() {
    return (
      <div className={ this.containerClasses() }>
        <FounderDashboardTargetHeader onClickCB={ this.handleClick } descriptionOpen={ this.state.showDescription }
          target={ this.props.target } displayDate={ this.props.displayDate } iconPaths={ this.props.iconPaths }/>

        <div className='founder-dashboard-target__description-container' id={ this.sliderId() }>
          <FounderDashboardTargetDescription key={ 'description-' + this.props.target.id }
            target={ this.props.target } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }
            founderDetails={ this.props.founderDetails} fetchFounderStatuses={ this.state.fetchFounderStatuses }
                                             fetchTargetPrerequisite={this.state.fetchTargetPrerequisite}
                                             fetchTargetFeedback={this.state.fetchTargetFeedback}/>
        </div>
      </div>
    );
  }
}

FounderDashboardTarget.propTypes = {
  target: React.PropTypes.object,
  openTimelineBuilderCB: React.PropTypes.func,
  displayDate: React.PropTypes.bool,
  iconPaths: React.PropTypes.object,
  founderDetails: React.PropTypes.array,
  selectTargetCB: React.PropTypes.func
};
