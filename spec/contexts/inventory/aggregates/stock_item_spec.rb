require "rails_helper"

RSpec.describe Inventory::StockItem, type: :model do
  let(:book_id) { SecureRandom.uuid }

  def create_stock(on_hand: 10, reserved: 0)
    Inventory::StockItem.create(
      book_id:,
      quantity_on_hand: on_hand,
      quantity_reserved: reserved
    )
  end

  describe "validations" do
    it "is valid with book_id and non-negative quantities" do
      stock = Inventory::StockItem.new(book_id: book_id, quantity_on_hand: 10, quantity_reserved: 0)
      expect(stock).to be_valid
    end

    it "is invalid without a book_id" do
      stock = Inventory::StockItem.new(book_id: nil)
      expect(stock).not_to be_valid
      expect(stock.errors[:book_id]).to include("can't be blank")
    end

    it "enforces book_id uniqueness" do
      create_stock
      duplicate = Inventory::StockItem.new(book_id: book_id, quantity_on_hand: 5)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:book_id]).to include("has already been taken")
    end

    it "is invalid with negative quantity_on_hand" do
      stock = Inventory::StockItem.new(book_id: book_id, quantity_on_hand: -1)
      expect(stock).not_to be_valid
    end

    it "is invalid with negative quantity_reserved" do
      stock = Inventory::StockItem.new(book_id: book_id, quantity_reserved: -1)
      expect(stock).not_to be_valid
    end
  end

  describe "#available_quantity" do
    it "returns on_hand minus reserved" do
      stock = create_stock(on_hand: 10, reserved: 3)
      expect(stock.available_quantity).to eq(7)
    end
  end

  describe "#can_reserve?" do
    it "returns true when enough stock available" do
      stock = create_stock(on_hand: 10, reserved: 3)
      expect(stock.can_reserve?(7)).to be true
    end

    it "returns false when not enough stock" do
      stock = create_stock(on_hand: 10, reserved: 3)
      expect(stock.can_reserve?(8)).to be false
    end

    it "returns true for exact available quantity" do
      stock = create_stock(on_hand: 10, reserved: 3)
      expect(stock.can_reserve?(7)).to be true
    end
  end

  describe "#reserve!" do
    it "increases quantity_reserved" do
      stock = create_stock(on_hand: 10, reserved: 0)
      stock.reserve!(5)
      expect(stock.reload.quantity_reserved).to eq(5)
    end

    it "raises InsufficientStockError when not enough stock" do
      stock = create_stock(on_hand: 10, reserved: 8)
      expect { stock.reserve!(5) }.to raise_error(Inventory::InsufficientStockError)
    end

    it "does not change quantity_on_hand" do
      stock = create_stock(on_hand: 10, reserved: 0)
      stock.reserve!(5)
      expect(stock.reload.quantity_on_hand).to eq(10)
    end
  end

  describe "#release!" do
    it "decreases quantity_reserved" do
      stock = create_stock(on_hand: 10, reserved: 5)
      stock.release!(3)
      expect(stock.reload.quantity_reserved).to eq(2)
    end

    it "does not go below zero" do
      stock = create_stock(on_hand: 10, reserved: 2)
      stock.release!(5)
      expect(stock.reload.quantity_reserved).to eq(0)
    end
  end

  describe "#deduct!" do
    it "decreases both on_hand and reserved" do
      stock = create_stock(on_hand: 10, reserved: 5)
      stock.deduct!(3)
      stock.reload
      expect(stock.quantity_on_hand).to eq(7)
      expect(stock.quantity_reserved).to eq(2)
    end
  end

  describe "#set_uuid" do
    it "generates a UUID on create" do
      stock = create_stock
      expect(stock.id).to match(/\A[0-9a-f-]{36}\z/)
    end
  end
end
