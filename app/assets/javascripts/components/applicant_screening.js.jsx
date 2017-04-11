class ApplicantScreening extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      selectedSide: null,
      baseKey: this.generateKey()
    };

    this.selectSectionCB = this.selectSectionCB.bind(this);
    this.resetCB = this.resetCB.bind(this);
  }

  generateKey() {
    return '' + (new Date).getTime();
  }

  containerClasses() {
    let classes = "content-box applicant-screening m-b-3";

    if (this.state.selectedSide == 'right') {
      classes += " applicant-screening--mobile-column-reverse";
    } else if (this.state.selectedSide == 'left') {
      classes += " applicant-screening--mobile-column";
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
    this.setState({selectedSide: null, baseKey: this.generateKey()});
  }

  render() {
    return (
      <div className={ this.containerClasses() }>
        <ApplicantScreeningSection key={ "section-left-" + this.state.baseKey } side="left"
          selectSectionCB={ this.selectSectionCB } resetCB={ this.resetCB } selectedSide={ this.state.selectedSide }
          iconPath={ this.props.coderIconPath } formAuthenticityToken={ this.props.formAuthenticityToken }/>
        <ApplicantScreeningSection key={ "section-right-" + this.state.baseKey } side="right"
          selectSectionCB={ this.selectSectionCB } resetCB={ this.resetCB } selectedSide={ this.state.selectedSide }
          iconPath={ this.props.nonCoderIconPath } formAuthenticityToken={ this.props.formAuthenticityToken }/>
      </div>
    );
  }
}

ApplicantScreening.propTypes = {
  coderIconPath: React.PropTypes.string,
  nonCoderIconPath: React.PropTypes.string,
  formAuthenticityToken: React.PropTypes.string
};
