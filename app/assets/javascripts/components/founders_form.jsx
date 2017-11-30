class FoundersForm extends React.Component {
  constructor(props) {
    super(props);

    let initialFounderKeys = [];

    for (let i = 0; i < this.props.founders.length; i++) {
      initialFounderKeys.push(this.generateKey(i));
    }

    this.state = {
      founders: this.props.founders,
      founderKeys: initialFounderKeys
    };

    this.addFounder = this.addFounder.bind(this);
    this.deleteFounderCB = this.deleteFounderCB.bind(this);
  }

  generateKey(index) {
    return '' + (new Date).getTime() + index;
  }

  addFounder() {
    let newFounder = {
      fields: {
        college_id: null,
        college_text: null,
        email: null,
        name: null,
        phone: null
      },
      errors: {}
    };

    let newIndex = this.state.founders.length;

    this.setState({
      founders: this.state.founders.concat([newFounder]),
      founderKeys: this.state.founderKeys.concat([this.generateKey(newIndex)])
    });
  }

  collegeName(founder) {
    let collegeId = founder.fields.college_id;

    if (collegeId !== null) {
      return this.props.collegeNames[collegeId];
    } else {
      return null;
    }
  }

  deleteFounderCB(index) {
    let updatedFounders = this.state.founders.slice();
    let updatedFounderKeys = this.state.founderKeys.slice();

    updatedFounders.splice(index, 1);
    updatedFounderKeys.splice(index, 1);

    this.setState({founders: updatedFounders, founderKeys: updatedFounderKeys});
  }

  allowDelete() {
    return this.state.founders.length > 1;
  }

  founderKey(index) {
    return this.state.founderKeys[index];
  }

  addFounderAllowed() {
    return this.state.founders.length < 4
  }

  hasErrors() {
    return Object.keys(this.props.errors).length > 0;
  }

  hasBaseErrors() {
    return this.baseErrorMessages().length > 0
  }

  baseErrorMessages() {
    if (typeof(this.props.errors.base) === 'undefined') {
      return [];
    } else {
      return this.props.errors.base;
    }
  }

  render() {
    return (
      <div>
        { this.hasErrors() &&
        <div className="alert alert-warning alert-dismissable fade in" role='alert'>
          <strong>There were problems with your submission. Please check all fields and try again.</strong>

          { this.hasBaseErrors() &&
          <ul className="m-t-1">
            {this.baseErrorMessages().map(function (baseErrorMessage,index) {
              return <li key={"error-"+ index }>{ baseErrorMessage }</li>;
            })}
          </ul>
          }
        </div>
        }

        <form className="simple_form form-horizontal" acceptCharset="UTF-8" method="post">
          <input name="utf8" type="hidden" value="✓"/>
          <input type="hidden" name="authenticity_token" value={ this.props.authenticityToken }/>

          <div className="founders-list">
            {this.state.founders.map(function (founder, index) {
              return (
                <FoundersFormFounderDetails founder={ founder } key={ this.founderKey(index) } index={ index }
                  generatedKey={ this.founderKey(index) } collegesUrl={ this.props.collegesUrl }
                  collegeName={ this.collegeName(founder) } deleteCB={ this.deleteFounderCB }
                  allowDelete={ this.allowDelete() }/>
              );
            }, this)}
          </div>

          <div className="clearfix">
            { this.addFounderAllowed() &&
            <div className="pull-sm-left m-b-1">
              <a className="btn btn-secondary btn-md founders-form__add-founder-button text-uppercase"
                onClick={ this.addFounder }>
                <i className="fa fa-plus" aria-hidden="true"/>&nbsp;&nbsp;Add founder
              </a>
            </div>
            }

            <div className="pull-sm-right m-b-1">
              <button type="submit" className="btn btn-primary btn-md text-uppercase">
                <i className="fa fa-floppy-o" aria-hidden="true"/>&nbsp;&nbsp;Save founders
              </button>
            </div>
          </div>
        </form>
      </div>
    )
  }
}

FoundersForm.propTypes = {
  authenticityToken: PropTypes.string,
  founders: PropTypes.array,
  errors: PropTypes.object,
  collegesUrl: PropTypes.string,
  collegeNames: PropTypes.object
};
