class ApplicantScreeningQuizResult extends React.Component {
  constructor(props) {
    super(props);
    this.reset = this.reset.bind(this);
  }

  reset() {
    this.props.resetCB()
  }

  render() {
    return (
      <div>
        This is the result: {String(this.props.passed)}
        <button onClick={ this.reset }>Reset</button>
      </div>
    );
  }
}

ApplicantScreeningQuizResult.propTypes = {
  passed: React.PropTypes.bool,
  resetCB: React.PropTypes.func
};
