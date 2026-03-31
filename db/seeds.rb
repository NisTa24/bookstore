puts "Seeding the DDD Bookstore..."

# Create Authors
authors = [
  Catalog::Author.find_or_create_by!(id: SecureRandom.uuid, name: "Eric Evans"),
  Catalog::Author.find_or_create_by!(id: SecureRandom.uuid, name: "Robert C. Martin"),
  Catalog::Author.find_or_create_by!(id: SecureRandom.uuid, name: "Martin Fowler"),
]
puts "  Created #{authors.size} authors"

# Create Categories
categories = {
  "software-design" => Catalog::Category.find_or_create_by!(id: SecureRandom.uuid, name: "Software Design", slug: "software-design"),
  "programming" => Catalog::Category.find_or_create_by!(id: SecureRandom.uuid, name: "Programming", slug: "programming"),
  "architecture" => Catalog::Category.find_or_create_by!(id: SecureRandom.uuid, name: "Architecture", slug: "architecture"),
}
puts "  Created #{categories.size} categories"

# Add Books via Command (triggers events: BookListing created + default Price set)
books_data = [
  { title: "Domain-Driven Design", isbn: "9780321125217", description: "Tackling complexity in the heart of software", author: authors[0], category: categories["software-design"] },
  { title: "Clean Code", isbn: "9780132350884", description: "A handbook of agile software craftsmanship", author: authors[1], category: categories["programming"] },
  { title: "Clean Architecture", isbn: "9780134494166", description: "A craftsman's guide to software structure and design", author: authors[1], category: categories["architecture"] },
  { title: "Patterns of Enterprise Application Architecture", isbn: "9780321127426", description: "Enterprise patterns and practices", author: authors[2], category: categories["architecture"] },
  { title: "Refactoring", isbn: "9780134757599", description: "Improving the design of existing code", author: authors[2], category: categories["programming"] },
]

book_ids = []
books_data.each do |data|
  next if Catalog::Book.exists?(isbn: data[:isbn])

  command = Catalog::Commands::AddBook.new
  command.on(:book_added) { |event| book_ids << event.book_id }
  command.call(
    title: data[:title],
    isbn: data[:isbn],
    description: data[:description],
    author_id: data[:author].id,
    category_id: data[:category].id
  )
end
puts "  Created #{book_ids.size} books (with auto-pricing at $9.99)"

# Set custom prices for some books
custom_prices = {
  "9780321125217" => 5499, # $54.99 for DDD
  "9780132350884" => 3999, # $39.99 for Clean Code
  "9780134494166" => 3499, # $34.99 for Clean Architecture
}

custom_prices.each do |isbn, cents|
  book = Catalog::Book.find_by(isbn: isbn)
  next unless book
  Pricing::Commands::SetBookPrice.call(
    book_id: book.id,
    amount_cents: cents,
    currency: "USD"
  )
end
puts "  Set custom prices for #{custom_prices.size} books"

# Register inventory for all books
Catalog::Book.find_each do |book|
  next if Inventory::StockItem.exists?(book_id: book.id)
  Inventory::Commands::RegisterStock.call(
    book_id: book.id,
    quantity: rand(5..25)
  )
end
puts "  Registered stock for #{Catalog::Book.count} books"

puts ""
puts "Seed complete!"
puts "  Books:       #{Catalog::Book.count}"
puts "  Prices:      #{Pricing::Price.count}"
puts "  Stock items: #{Inventory::StockItem.count}"
puts "  Listings:    #{Catalog::ReadModels::BookListing.count}"
puts "  Events log:  #{Shared::DomainEventLog.count}"
