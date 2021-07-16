class Items
  @@items = {}

  class << self
    def all
      @@items.values
    end

    def find(id)
      @@items[id.to_i] { Item.new }
    end

    def create(params)
      update(params)
    end

    def update(params)
      item = Item.new(params)
      @@items[params[:id].to_i] = item
      item
    end

    def remove(id)
      @@items.delete(id.to_i)
    end
  end
end
