import React from 'react';

import Item from './item';

export default class List extends React.Component {
  constructor(props) {
    super(props);

    this.store = props.store;
    this.state = { items: [] };

    this.addItem = this.addItem.bind(this);
    this.updateItem = this.updateItem.bind(this);
    this.removeItem = this.removeItem.bind(this);
  }

  async componentDidMount() {
    const items = await this.store.list();
    this.setState({ items: items });
  }

  addItem(e) {
    e.preventDefault();
    const input = e.target.querySelector('input');

    const rand = new Uint32Array(1);
    window.crypto.getRandomValues(rand);

    const item = {
      id: rand[0],
      text: input.value,
      done: false,
    };

    this.store.add(item);

    this.setState({ items: this.state.items.concat(item) });
    input.value = '';
  }

  updateItem(item) {
    this.store.update(item);

    this.setState(state => {
      const items = state.items.map(i => {
        if (i.id === item.id) {
          return item
        }

        return i;
      });

      return {items};
    });
  }

  removeItem(id) {
    this.store.remove(id);

    this.setState(state => {
      const items = state.items.filter(i => i.id !== id);
      return {items};
    });
  }

  render() {
    const items = this.state.items.map(i => (
      <Item
        key={i.id}
        id={i.id}
        text={i.text}
        done={i.done}
        updateItem={this.updateItem}
        removeItem={this.removeItem}
      />
    ));

    return (
      <div className="list">
        <ul>
          {items}
        </ul>
        <form onSubmit={this.addItem}>
          <input placeholder="What would you like to do?"></input>
          <button type="submit">Add</button>
        </form>
      </div>
    );
  }
}
