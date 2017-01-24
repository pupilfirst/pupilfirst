class ApplicantScreening extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      selectedSide: null
    };

    this.selectSectionCB = this.selectSectionCB.bind(this);
  }

  containerClasses() {
    let classes = "content-box applicant-screening m-b-3";

    if (this.state.selectedSide == 'right') {
      classes += " applicant-screening__reverse-order"
    }

    return classes;
  }

  selectSectionCB(type) {
    if (type === 'coder') {
      this.setState({selectedSide: 'left'});
    } else if (type === 'non-coder') {
      this.setState({selectedSide: 'right'});
    }
  }

  resetCB() {
    this.setState({selectedSide: null});
  }

  render() {
    return (
      <div className={ this.containerClasses() }>
        <ApplicantScreeningSection key="section-left" side="left" selectSectionCB={ this.selectSectionCB }
          resetCB={ this.resetCB }
          selectedSide={ this.state.selectedSide } iconPath={ this.props.coderIconPath }/>
        <ApplicantScreeningSection key="section-right" side="right" selectSectionCB={ this.selectSectionCB }
          resetCB={ this.resetCB }
          selectedSide={ this.state.selectedSide } iconPath={ this.props.nonCoderIconPath }/>
      </div>
    );
  }
}

ApplicantScreening.propTypes = {
  coderIconPath: React.PropTypes.string,
  nonCoderIconPath: React.PropTypes.string
};
