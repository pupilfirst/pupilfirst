class CofoundersFormCofounderDetails extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      useCollegeText: false
    };

    this.handleCollegeChange = this.handleCollegeChange.bind(this);
  }

  canDelete() {
    return true;
  }

  componentDidMount() {
    let collegeSelect = $('#' + this.selectId());

    collegeSelect.select2({
      minimumInputLength: 3,
      placeholder: 'Please pick your college',
      ajax: {
        url: this.props.collegesUrl,
        dataType: 'json',
        delay: 500,
        data: function (params) {
          return {
            q: params.term
          }
        },
        processResults: function (data, params) {
          return {results: data}
        },
        cache: true
      }
    });

    collegeSelect.on('change', this.handleCollegeChange)
  }

  componentWillUnmount() {
    this.destroySelect2();
  }

  destroySelect2() {
    $(this.selectId()).select2('destroy');
  }

  selectId() {
    return "cofounders-form__college-select-" + this.props.index;
  }

  handleCollegeChange(event) {
    if (event.target.value === 'other') {
      this.destroySelect2();
      this.setState({useCollegeText: true});
    }
  }

  errorForField(field) {
    return this.props.cofounder.errors[field][0];
  }

  render() {
    return (
      <div className="cofounder content-box">
        { this.canDelete() &&
        <div className="cofounder-delete-button">
          <i className="fa fa-times-circle"/>
        </div>
        }

        <CofoundersFormCofounderInput label="Name" index={ this.props.index } key={ "name-" + this.props.index }
                                      maxLength={ 250 } name="name" type="string"/>

        <CofoundersFormCofounderInput label="Email address" index={ this.props.index }
                                      key={ "email-" + this.props.index } maxLength={ 250 } name="email" type="email"
                                      error={ this.errorForField('email') }/>

        <CofoundersFormCofounderInput label="Mobile phone number" index={ this.props.index }
                                      key={ "phone-" + this.props.index } maxLength={ 17 } name="phone" type="tel"
                                      pattern="\+?[0-9]{8,16}"/>

        { !this.state.useCollegeText &&
        <div className="form-group select required batch_applications_cofounders_cofounders_college_id">
          <label className="control-label select required"
                 htmlFor="batch_applications_cofounders_cofounders_attributes_0_college_id">
            <abbr title="required">*</abbr> College
          </label>

          <select
            className="form-control select required" required="required"
            aria-required="true"
            name="batch_applications_cofounders[cofounders_attributes][0][college_id]"
            id={ this.selectId() }>
            <option value=""/>
            <option value="other">My college isn't listed</option>
          </select>
        </div>
        }

        { this.state.useCollegeText &&
        <CofoundersFormCofounderInput label="Name of your college" index={ this.props.index } type="string"
                                      key={ "college-text-" + this.props.index } maxLength={ 250 }
                                      name="college_text"/>
        }
      </div>
    );
  }
}

CofoundersFormCofounderDetails.propTypes = {
  cofounder: React.PropTypes.object,
  collegesUrl: React.PropTypes.string,
  index: React.PropTypes.number
};
