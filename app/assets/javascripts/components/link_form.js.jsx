var LinkForm = React.createClass({
  propTypes: {
    link: React.PropTypes.string
  },

  getInitialState: function() {
    return {title: this.props.title, url: this.props.url, private: this.props.private};
  },

  saveLink: function() {
    new_title = document.getElementById('link_title').value
    new_url = document.getElementById('link_url').value
    new_private = document.getElementById('link_private').checked
    this.props.linkAddedCallBack(new_title, new_url, new_private);
  },

  render: function() {
    return (
          <div>
            { this.props.link ? (<h4>Edit Link</h4>) : (<h4>Add Link</h4>)}
            <div className="form-horizontal">
              <div className="form-group" id="link-title-group">
                <label for="link_title" className="col-sm-2 control-label">Title</label>
                <div className="col-sm-10">
                  <input id="link_title" className="form-control" type="text" placeholder="(required)" name="link_title" value={this.state.title}>
                  </input>
                  <span className="glyphicon glyphicon-remove form-control-feedback hidden">
                  </span>
                </div>
              </div>
              <div className="form-group" id="link-url-group">
                <label for="link_url" className="col-sm-2 control-label">URL</label>
                <div className="col-sm-10">
                  <input id="link_url" className="form-control" type="text" placeholder="(required)" name="link_url" value={this.state.url}>
                  </input>
                  <span className="glyphicon glyphicon-remove form-control-feedback hidden">
                  </span>
                  <span id="url-help" className="help-block hidden"></span>
                </div>
              </div>
              <div className="form-group">
                <div className="col-sm-offset-2 col-sm-10">
                  <div className="checkbox">
                    <label>
                      <input id="link_private" type="checkbox" name="link_private" value={this.state.private}></input>
                      <span id="hide-from-public" data-toggle="tooltip" data-placement="bottom" title="If checked, this link will be visible only to you, co-founders, and SV.CO Team members." href='#'>
                        Hide from public?
                      </span>
                    </label>
                  </div>
                </div>
                <div className="col-sm-offset-2 col-sm-10 margin-top-20">
                  <button onClick={this.saveLink} className="btn btn-success" ><i className="fa fa-plus"></i> Save Link</button>
                </div>
              </div>
            </div>
          </div>
    );
  }
});
