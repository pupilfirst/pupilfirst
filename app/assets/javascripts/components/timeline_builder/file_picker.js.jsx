class TimelineBuilderFilePicker extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      fileLabel: '',
      hasError: props.hasError
    };
    this.handleChange = this.handleChange.bind(this);
  }

  componentWillReceiveProps(newProps) {
    this.setState({hasError: newProps.hasError});
  }

  handleChange(event) {
    let fileName = $(event.target).val().split('\\').pop();
    let newLabelText = fileName ? fileName : '';
    this.setState({fileLabel: newLabelText, hasError: false});
  }

  formGroupClassNames() {
    return ("form-group timeline-builder__form-group timeline-builder__file-choose-group" + (this.state.hasError ? ' has-danger' : ''));
  }

  render() {
    return (
      <div className={ this.formGroupClassNames() } >
        <input type="file" className="form-control-file timeline-builder__file-choose js-attachment-file"
               id="timeline-builder__file-input" onChange={ this.handleChange }/>
        <label className="timeline-builder__file-label" htmlFor="timeline-builder__file-input">
          <span className="timeline-builder__file-name">{ this.state.fileLabel }</span>
          <div className="timeline-builder__choose-file-btn">
            <i className="timeline-builder__choose-file-btn-icon fa fa-upload"/>
            CHOOSE FILE
          </div>
        </label>
        { this.state.hasError &&
        <div className="form-control-feedback m-t-0">Choose a valid file!</div>
        }
      </div>
    )
  }
}
