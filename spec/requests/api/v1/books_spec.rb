require "rails_helper"

RSpec.describe "Api::V1::Books", type: :request do
  describe "GET /api/v1/books" do
    before do
      Catalog::ReadModels::BookListing.create(
        book_id: "b1", title: "Book One", isbn: "9780306406157", status: "active"
      )
      Catalog::ReadModels::BookListing.create(
        book_id: "b2", title: "Book Two", isbn: "0306406152", status: "active"
      )
      Catalog::ReadModels::BookListing.create(
        book_id: "b3", title: "Retired", isbn: "9780134685991", status: "retired"
      )
    end

    it "returns active book listings" do
      get "/api/v1/books"
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      titles = json.map { |b| b["title"] }
      expect(titles).to include("Book One", "Book Two")
      expect(titles).not_to include("Retired")
    end
  end

  describe "GET /api/v1/books/:id" do
    let!(:listing) do
      Catalog::ReadModels::BookListing.create(
        book_id: "b1", title: "Test Book", isbn: "9780306406157", status: "active"
      )
    end

    it "returns the book listing" do
      get "/api/v1/books/b1"
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["title"]).to eq("Test Book")
    end

    it "returns 404 for unknown book" do
      get "/api/v1/books/nonexistent"
      expect(response).to have_http_status(:not_found)

      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Book not found")
    end
  end

  describe "POST /api/v1/books" do
    let(:valid_params) do
      { book: { title: "New Book", isbn: "9780306406157", description: "A test book" } }
    end

    it "creates a book and returns 201" do
      post "/api/v1/books", params: valid_params
      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["title"]).to eq("New Book")
      expect(json["isbn"]).to eq("9780306406157")
      expect(json["message"]).to eq("Book added to catalog")
    end

    it "creates a Catalog::Book record" do
      expect {
        post "/api/v1/books", params: valid_params
      }.to change(Catalog::Book, :count).by(1)
    end

    it "returns 422 for invalid params" do
      post "/api/v1/books", params: { book: { title: "", isbn: "bad" } }
      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end

    it "returns 422 for duplicate ISBN" do
      Catalog::Book.create(title: "Existing", isbn: "9780306406157", status: "active")

      post "/api/v1/books", params: valid_params
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/books/:id" do
    let!(:book) { Catalog::Book.create(title: "Old Title", isbn: "9780306406157", status: "active") }

    before do
      Catalog::ReadModels::BookListing.create(
        book_id: book.id, title: "Old Title", isbn: "9780306406157", status: "active"
      )
    end

    it "updates the book" do
      patch "/api/v1/books/#{book.id}", params: { book: { title: "Updated Title" } }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["title"]).to eq("Updated Title")
      expect(json["message"]).to eq("Book updated")
    end

    it "returns 422 for invalid book_id" do
      patch "/api/v1/books/nonexistent", params: { book: { title: "X" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/books/:id" do
    let!(:book) { Catalog::Book.create(title: "To Retire", isbn: "9780306406157", status: "active") }

    it "retires the book" do
      delete "/api/v1/books/#{book.id}"
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Book retired")
      expect(book.reload.status).to eq("retired")
    end

    it "returns 422 for nonexistent book" do
      delete "/api/v1/books/nonexistent"
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
