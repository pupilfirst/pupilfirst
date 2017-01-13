class TimelineBuilderFilePicker extends React.Component {
  constructor(props) {
    super(props);
    this.state = {fileLabel: ''};
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    let fileName = $(event.target).val().split('\\').pop();
    let newLabelText = fileName ? fileName : '';
    this.setState({fileLabel: newLabelText});
    this.props.clearErrorsCB();
  }

  hasAnyError() {
    return this.props.fileMissingError || this.props.fileSizeError
  }

  formGroupClassNames() {
    return ("form-group timeline-builder__form-group" + (this.hasAnyError() ? ' has-danger' : ''));
  }

  render() {
    return (
      <div className={ this.formGroupClassNames() }>
        <input type="file" className="form-control-file timeline-builder__file-input js-hook"
               id="timeline-builder__file-input" onChange={ this.handleChange }/>
        <label className="timeline-builder__file-label" htmlFor="timeline-builder__file-input">
          <span className="timeline-builder__file-name">{ this.state.fileLabel }</span>
          <div className="timeline-builder__choose-file-btn">
            <i className="timeline-builder__choose-file-btn-icon fa fa-upload"/>
            CHOOSE FILE
          </div>
        </label>
        { this.props.fileMissingError &&
        <div className="form-control-feedback m-t-0">Choose a valid file!</div>
        }
        { this.props.fileSizeError &&
        <div className="form-control-feedback m-t-0">Size cannot exceed 5MB!</div>
        }
      </div>
    )
  }
}

TimelineBuilderFilePicker.propTypes = {
  clearErrorsCB: React.PropTypes.func,
  fileMissingError: React.PropTypes.bool,
  fileSizeError: React.PropTypes.bool
};
