import React from 'react';

export default class Item extends React.Component {
  constructor(props) {
    super(props);

    this.updateItem = props.updateItem;
    this.removeItem = props.removeItem;

    this.wasChecked = this.wasChecked.bind(this);
    this.wasRemoved = this.wasRemoved.bind(this);
  }

  wasChecked(e) {
    this.updateItem({
      id: this.props.id,
      text: this.props.text,
      done: !this.props.done,
    });
  }

  wasRemoved(e) {
    this.removeItem(this.props.id);
  }

  render() {
    let className = '';
    if (this.props.done) {
      className = 'done';
    }

    return (
      <li className={className}>
        <input type="checkbox" checked={this.props.done} onChange={this.wasChecked} />
        <div className="text">{this.props.text}</div>
        <div className="remove" onClick={this.wasRemoved}>&times;</div>
      </li>
    );
  }
}
