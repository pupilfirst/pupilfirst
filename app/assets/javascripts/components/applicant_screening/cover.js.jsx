class ApplicantScreeningCover extends React.Component {
  constructor(props) {
    super(props);

    this.selectSection = this.selectSection.bind(this);
  }

  containerClasses() {
    let classes = "applicant-screening__cover";
    classes += ' ' + this.props.type + "-cover";
    return classes;
  }

  selectSection() {
    this.props.selectSectionCB(this.props.type);
  }

  render() {
    return (
      <div className={ this.containerClasses() }>
        <div className="applicant-screening__cover-content">
          <div className="applicant-screening__icon img-circle">
            <img className="applicant-screening__icon-img" src={ this.props.iconPath }/>
          </div>

          <h2 className="applicant-screening-choice">
            { this.props.type === 'coder' &&
            <span>
              Yes, I am a
              <div className="font-semibold">good programmer</div>
            </span>
            }

            { this.props.type === 'non-coder' &&
            <span>
              No, I have
              <div className="font-semibold">other skills</div>
            </span>
            }
          </h2>

          { !this.props.selected &&
          <button className="btn btn-primary btn-md applicant-screening-btn" onClick={ this.selectSection }>
            <span>START</span>
          </button>
          }
        </div>
      </div>
    );
  }
}

ApplicantScreeningCover.propTypes = {
  type: React.PropTypes.string,
  iconPath: React.PropTypes.string,
  selectSectionCB: React.PropTypes.func,
  selected: React.PropTypes.bool
};
