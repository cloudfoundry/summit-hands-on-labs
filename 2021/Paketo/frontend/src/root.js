import React from 'react';

import List from './list';

export default class Root extends React.Component {
  constructor(props) {
    super(props);

    this.store = props.store;
  }

  render() {
    return (
      <div className="root">
        <h1>My List</h1>
        <List store={this.store} />
      </div>
    );
  }
}
