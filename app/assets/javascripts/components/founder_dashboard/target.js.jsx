class FounderDashboardTarget extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      showDescription: false,
      fetchFounderStatuses: false
    };

    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    let newShowDescription = !this.state.showDescription;

    this.setState({showDescription: newShowDescription});

    this.animateDescription(newShowDescription);
  }

  animateDescription(open) {
    if (open) {
      if (!this.state.fetchFounderStatuses) {
        this.setState({fetchFounderStatuses: true});
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
                                             founderDetails={ this.props.founderDetails}
                                             fetchFounderStatuses={ this.state.fetchFounderStatuses }/>
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
  founderDetails: React.PropTypes.array
};
