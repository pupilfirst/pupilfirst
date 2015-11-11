var LinkForm = React.createClass({
  propTypes: {
    link: React.PropTypes.object
  },

  getInitialState: function () {
    if (!this.props.link) {
      //if no links received, initialize an empty object so that we can still call link.title etc
      var initialLink = {"title": "", "url": "", "private": false};
    } else {
      var initialLink = this.props.link;
    }
    return {link: initialLink, titleError: false, urlError: false};
  },

  //updates the open form if user changes its role (by clicking edit on another link for eg)
  componentWillReceiveProps: function (newProps) {
    this.setState({link: newProps.link})
  },

  handleInputChange: function (event) {
    //copy links to a new object to avoid pass by reference
    var presentLink = $.extend({},this.state.link);
    switch(event.target.id) {
      case "link_title":
        presentLink.title = event.target.value;
        break;
      case "link_url":
        presentLink.url = event.target.value;
        break;
      case "link_private":
        presentLink.private = event.target.checked;
        break;
    }
    this.setState({link: presentLink});
  },

  saveLink: function () {
    var new_title = $('#link_title').val();
    var new_url = $('#link_url').val();
    var new_private = $('#link_private').prop('checked');
    if (new_title && this.isUrlValid(new_url)) {
      if (!this.linkProvided()) {
        this.props.linkAddedCB({"title": new_title, "url": new_url, "private": new_private});
      } else {
        this.props.editLinkCB({"title": new_title, "url": new_url, "private": new_private, "index": this.state.link.index});
      }
    } else {
      if ( !new_title ) {
        this.setState({titleError: true});
      }
      if ( !this.isUrlValid(new_url) ) {
        this.setState({urlError: true});
      }
    }
  },

  isUrlValid: function (url) {
    return /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url);
  },

  //upon focus, clear error markers, if any
  clearErrorMarkers: function(event) {
    if ( event.target.id == "link_title" ) {
      this.setState({titleError: false});
    } else if ( event.target.id == "link_url" ) {
      this.setState({urlError: false});
    }
  },

  linkProvided: function() {
    //link.index will be 'undefined' for 'Add Link'
    return typeof(this.state.link.index) == "number";
  },


  render: function () {
    return (
      <div>
        { this.linkProvided() ? (<h4>Edit Link</h4>) : (<h4>Add Link</h4>)}
        <div className="form-horizontal">
          <div className={ (this.state.titleError ? 'has-error has-feedback ' : '') + 'form-group' } id="link-title-group">
            <label htmlFor="link_title" className="col-sm-2 control-label">Title</label>

            <div className="col-sm-10">
              <input id="link_title" className="form-control" type="text" placeholder="(required)" name="link_title"
                     value={ this.state.link.title } onFocus={this.clearErrorMarkers} onChange={ this.handleInputChange }>
              </input>
                  <span className={ (this.state.titleError ? '' : 'hidden ') + "glyphicon glyphicon-remove form-control-feedback" }>
                  </span>
            </div>
          </div>
          <div className={ (this.state.urlError ? 'has-error has-feedback ' : '') + 'form-group' } id="link-url-group">
            <label htmlFor="link_url" className="col-sm-2 control-label">URL</label>

            <div className="col-sm-10">
              <input id="link_url" className="form-control" type="text" placeholder="(required)" name="link_url"
                     value={ this.state.link.url } onFocus={this.clearErrorMarkers} onChange={ this.handleInputChange }>
              </input>
                  <span className={ (this.state.urlError ? '' : 'hidden ') + "glyphicon glyphicon-remove form-control-feedback" }>
                  </span>
              <span id="url-help" className={ (this.state.urlError ? '' : 'hidden  ') +'help-block' }>
                Please make sure you've supplied a full URL, starting with http(s).
              </span>
            </div>
          </div>
          <div className="form-group">
            <div className="col-sm-offset-2 col-sm-10">
              <div className="checkbox">
                <label>
                  <input id="link_private" type="checkbox" name="link_private" checked={ this.state.link.private } onChange={ this.handleInputChange }></input>
                      <span id="hide-from-public" data-toggle="tooltip" data-placement="bottom"
                            title="If checked, this link will be visible only to you, co-founders, and SV.CO Team members."
                            href='#'>
                        Hide from public?
                      </span>
                </label>
              </div>
            </div>
            <div className="col-sm-offset-2 col-sm-10 margin-top-20">
              <button onClick={this.saveLink} className="btn btn-success"><i className="fa fa-plus"></i> Save Link
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }
});
