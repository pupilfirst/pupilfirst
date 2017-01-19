class CofoundersForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      cofounders: this.props.cofounders
    };

    this.addCofounder = this.addCofounder.bind(this);
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
      errors: {
        college_id: [],
        college_text: [],
        email: [],
        name: [],
        phone: []
      }
    };

    this.setState({cofounders: this.state.cofounders.concat([newCofounder])});
  }

  collegeName(cofounder) {
    let collegeId = cofounder.fields.college_id;

    if (collegeId !== null) {
      return this.props.collegeNames[collegeId];
    } else {
      return null;
    }
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
                <CofoundersFormCofounderDetails cofounder={ cofounder } key={ index } index={ index }
                  collegesUrl={ this.props.collegesUrl }
                  collegeName={ this.collegeName(cofounder) }/>
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
