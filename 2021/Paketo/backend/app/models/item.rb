class Item
  attr_accessor :id, :text, :done

  def initialize(params)
    self.id = params[:id].to_i
    self.text = params[:text] || ""
    self.done = params[:done] || false
  end
end
