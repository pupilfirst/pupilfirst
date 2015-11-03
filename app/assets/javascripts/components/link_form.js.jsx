var LinkForm = React.createClass({
  propTypes: {
    link: React.PropTypes.string
  },

  getInitialState: function () {
    return {
      title: this.props.title,
      url: this.props.url,
      private: this.props.private,
      titleError: false,
      urlError: false
    };
  },

  saveLink: function () {
    var new_title = $('#link_title').val();
    var new_url = $('#link_url').val();
    var new_private = $('#link_private').prop('checked');
    if (new_title && this.isUrlValid(new_url)) {
      this.props.linkAddedCallBack(new_title, new_url, new_private);
    } else {
      if (!new_title) {
        this.setState({titleError: true});
      }
      if (!this.isUrlValid(new_url)) {
        this.setState({urlError: true});
      }
    }
  },

  isUrlValid: function (url) {
    return /^(https?|s?ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url);
  },

  clearErrorMarkers: function (event) {
    if (event.target.id == "link_title") {
      this.setState({titleError: false});
    } else if (event.target.id == "link_url") {
      this.setState({urlError: false});
    }
  },

  render: function () {
    return (
      <div>
        { this.props.link ? (<h4>Edit Link</h4>) : (<h4>Add Link</h4>)}
        <div className="form-horizontal">
          <div className={ (this.state.titleError ? 'has-error has-feedback ' : '') + 'form-group' }
               id="link-title-group">
            <label htmlFor="link_title" className="col-sm-2 control-label">Title</label>

            <div className="col-sm-10">
              <input id="link_title" className="form-control" type="text" placeholder="(required)" name="link_title"
                     value={this.state.title} onFocus={this.clearErrorMarkers}>
              </input>
                  <span
                    className={ (this.state.titleError ? '' : 'hidden ') + "glyphicon glyphicon-remove form-control-feedback" }>
                  </span>
            </div>
          </div>
          <div className={ (this.state.urlError ? 'has-error has-feedback ' : '') + 'form-group' } id="link-url-group">
            <label htmlFor="link_url" className="col-sm-2 control-label">URL</label>

            <div className="col-sm-10">
              <input id="link_url" className="form-control" type="text" placeholder="(required)" name="link_url"
                     value={this.state.url} onFocus={this.clearErrorMarkers}>
              </input>
                  <span
                    className={ (this.state.urlError ? '' : 'hidden ') + "glyphicon glyphicon-remove form-control-feedback" }>
                  </span>
              <span id="url-help" className={ (this.state.urlError ? '' : 'hidden ') +'help-block' }>
                Please make sure you've supplied a full URL, starting with http(s).
              </span>
            </div>
          </div>
          <div className="form-group">
            <div className="col-sm-offset-2 col-sm-10">
              <div className="checkbox">
                <label>
                  <input id="link_private" type="checkbox" name="link_private" value={this.state.private}></input>
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
