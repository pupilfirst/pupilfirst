class ApplicantScreeningSection extends React.Component {
  containerClasses() {
    let baseClass = 'applicant-screening__section-' + this.props.side;
    let classes = 'applicant-screening__section ' + baseClass;

    if (this.isQuiz()) {
      classes += ' ' + baseClass + "--expanded";
    } else if (this.isCover() && this.props.selectedSide !== null) {
      classes += ' ' + baseClass + "--shrunk";
    }

    return classes;
  }

  isCover() {
    return this.props.selectedSide === null || this.props.selectedSide === this.props.side;
  }

  isQuiz() {
    return this.props.selectedSide !== this.props.side && this.props.selectedSide !== null;
  }

  coverType() {
    if (this.props.side === 'left') {
      return 'coder';
    } else {
      return 'non-coder';
    }
  }

  quizType() {
    if (this.props.side === 'left') {
      return 'non-coder';
    } else {
      return 'coder';
    }
  }

  render() {
    return (
      <div className={ this.containerClasses() }>
        { this.isCover() &&
        <ApplicantScreeningCover type={ this.coverType() } selectSectionCB={ this.props.selectSectionCB }
          iconPath={ this.props.iconPath } selected={ this.props.selectedSide !== null }/>
        }

        { this.isQuiz() &&
        <ApplicantScreeningQuiz type={ this.quizType() } resetCB={ this.props.resetCB }
          formAuthenticityToken={ this.props.formAuthenticityToken }/>
        }
      </div>
    );
  }
}

ApplicantScreeningSection.propTypes = {
  side: PropTypes.string,
  iconPath: PropTypes.string,
  selectedSide: PropTypes.string,
  selectSectionCB: PropTypes.func,
  resetCB: PropTypes.func,
  formAuthenticityToken: PropTypes.string
};
