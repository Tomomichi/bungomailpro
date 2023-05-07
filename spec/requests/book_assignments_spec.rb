require "rails_helper"

RSpec.describe "BookAssignments", type: :request do
  let(:user) { create(:user, :basic) }
  let(:trial_user) { create(:user, :trial_scheduled) }
  let(:non_authorized_user) { create(:user) }
  let(:admin_user) { User.find_by(email: "info@notsobad.jp") }
  let(:book) { create(:aozora_book) }
  let!(:book_assignment) { create(:book_assignment, book: book) }

  describe "GET /book_assignments" do
    it "returns http success" do
      get book_assignments_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /book_assignments/:id" do
    it "returns http success" do
      get book_assignment_path(book_assignment)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /book_assignments" do
    context "when user has a basic plan" do
      before { login(user) }

      it "creates a new book assignment and redirects to its show page" do
        expect {
          post book_assignments_path, params: { book_assignment: { book_id: book.id, book_type: "some_type", start_date: Date.today, end_date: Date.today + 1.week, delivery_time: "10:00", delivery_method: "email" } }
        }.to change(BookAssignment, :count).by(1)
        expect(response).to redirect_to(book_assignment_path(BookAssignment.last))
      end
    end

    context "when user is in trial period" do
      before { login(trial_user) }

      it "creates a new book assignment and redirects to its show page" do
        expect {
          post book_assignments_path, params: { book_assignment: { book_id: book.id, book_type: "some_type", start_date: Date.today, end_date: Date.today + 1.week, delivery_time: "10:00", delivery_method: "email" } }
        }.to change(BookAssignment, :count).by(1)
        expect(response).to redirect_to(book_assignment_path(BookAssignment.last))
      end
    end

    context "when user does not have proper permission" do
      before { login(non_authorized_user) }

      it "does not create a new book assignment and redirects" do
        expect {
          post book_assignments_path, params: { book_assignment: { book_id: book.id, book_type: "some_type", start_date: Date.today, end_date: Date.today + 1.week, delivery_time: "10:00", delivery_method: "email" } }
        }.not_to change(BookAssignment, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /book_assignments/:id" do
    context "when user is the owner of the book_assignment and not an admin" do
      before { login(user) }

      it "deletes the book assignment and redirects to mypage" do
        expect {
          delete book_assignment_path(book_assignment)
        }.to change(BookAssignment, :count).by(-1)
        expect(response).to redirect_to(mypage_path)
      end
    end

    context "when user is not the owner of the book_assignment" do
      before { login(admin_user) }

      it "does not delete the book assignment and redirects" do
        expect {
          delete book_assignment_path(book_assignment)
        }.not_to change(BookAssignment, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
