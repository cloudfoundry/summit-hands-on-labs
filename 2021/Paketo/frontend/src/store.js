export default class Store {
  constructor(props) {
    this.host = props.host;
  }

  async list() {
    const response = await fetch(`${this.host}/items`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    return await response.json();
  }

  async add(item) {
    const response = await fetch(`${this.host}/items`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(item),
    });

    return await response.json();
  }

  async update(item) {
    const response = await fetch(`${this.host}/items/${item.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(item),
    });

    return await response.json();
  }

  async remove(id) {
    await fetch(`${this.host}/items/${id}`, {
      method: 'DELETE',
    });
  }
}
