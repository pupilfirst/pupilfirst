class CofoundersForm extends React.Component {
  constructor(props) {
    super(props);

    let initialCofounderKeys = [];

    for (let i = 0; i < this.props.cofounders.length; i++) {
      initialCofounderKeys.push(this.generateKey(i));
    }

    this.state = {
      cofounders: this.props.cofounders,
      cofounderKeys: initialCofounderKeys
    };

    this.addCofounder = this.addCofounder.bind(this);
    this.deleteCofounderCB = this.deleteCofounderCB.bind(this);
  }

  generateKey(index) {
    return '' + (new Date).getTime() + index;
  }

  addCofounder() {
    let newCofounder = {
      fields: {
        college_id: null,
        college_text: null,
        email: null,
        name: null,
        phone: null
      },
      errors: {}
    };

    let newIndex = this.state.cofounders.length;

    this.setState({
      cofounders: this.state.cofounders.concat([newCofounder]),
      cofounderKeys: this.state.cofounderKeys.concat([this.generateKey(newIndex)])
    });
  }

  collegeName(cofounder) {
    let collegeId = cofounder.fields.college_id;

    if (collegeId !== null) {
      return this.props.collegeNames[collegeId];
    } else {
      return null;
    }
  }

  deleteCofounderCB(index) {
    let updatedCofounders = this.state.cofounders.slice();
    let updatedCofounderKeys = this.state.cofounderKeys.slice();

    updatedCofounders.splice(index, 1);
    updatedCofounderKeys.splice(index, 1);

    gthis.setState({cofounders: updatedCofounders, cofounderKeys: updatedCofounderKeys});
  }

  allowDelete() {
    return this.state.cofounders.length > 1;
  }

  cofounderKey(index) {
    return this.state.cofounderKeys[index];
  }

  render() {
    return (
      <div className="apply-cofounders-form">
        <form className="simple_form form-horizontal" action={ this.props.path } acceptCharset="UTF-8" method="post">
          <input name="utf8" type="hidden" value="✓"/>
          <input type="hidden" name="authenticity_token" value={ this.props.authenticityToken }/>

          <div className="cofounders-list">
            {this.state.cofounders.map(function (cofounder, index) {
              return (
                <CofoundersFormCofounderDetails cofounder={ cofounder } key={ this.cofounderKey(index) } index={ index }
                  generatedKey={ this.cofounderKey(index) } collegesUrl={ this.props.collegesUrl }
                  collegeName={ this.collegeName(cofounder) } deleteCB={ this.deleteCofounderCB }
                  allowDelete={ this.allowDelete() }/>
              );
            }, this)}
          </div>

          <div className="clearfix">
            <div className="pull-sm-left m-b-1">
              <a className="btn btn-secondary cofounders-form__add-cofounder-button text-uppercase"
                onClick={ this.addCofounder }>
                <i className="fa fa-plus"/> Add cofounder
              </a>
            </div>

            <div className="pull-sm-right m-b-1">
              <button type="submit" className="btn btn-success text-uppercase">Save cofounders</button>
            </div>
          </div>
        </form>
      </div>
    )
  }
}

CofoundersForm.propTypes = {
  authenticityToken: React.PropTypes.string,
  path: React.PropTypes.string,
  cofounders: React.PropTypes.array,
  errors: React.PropTypes.object,
  collegesUrl: React.PropTypes.string,
  collegeNames: React.PropTypes.object
};
