require 'rails_helper'

RSpec.describe CalculatorController, type: :controller do
  describe "POST #add" do
    context "with valid input" do
      it "returns 0 for 0" do
        post :add, params: { numbers: "0" }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["result"]).to eq(0)
      end

      it "returns the sum of one number" do
        post :add, params: { numbers: "2" }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["result"]).to eq(2)
      end

      it "returns the sum of two numbers seperated by ," do
        post :add, params: { numbers: "1,2,6" }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["result"]).to eq(9)
      end

      it "returns the sum of two numbers seperated by ;" do
        post :add, params: { numbers: "//;\n1;2" }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["result"]).to eq(3)
      end

      it "returns the sum of 3 numbers seperated by new_line and ;" do
        post :add, params: { numbers: "//;\n1;2;8" }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["result"]).to eq(11)
      end

      it "returns the sum of 3 numbers seperated by new_line and ," do
        post :add, params: { numbers: "1\n2,3" }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["result"]).to eq(6)
      end
    end

    context "with invalid input" do
      it "returns an error message" do
        post :add, params: { numbers: "1\\n" }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Invalid input")
      end
    end

    context "with negative numbers" do
      it "returns an error message with 2 negative numbers" do
        post :add, params: { numbers: "-1,9,-78" }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Negative numbers not allowed: -1,-78")
      end

      it "returns an error message with 1 negative number" do
        post :add, params: { numbers: "10,-6,7" }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Negative numbers not allowed: -6")
      end

      it "returns an error message with multiple negative numbers" do
        post :add, params: { numbers: "//;\\n1;-2;8,-9,-80;\\n-7" }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Negative numbers not allowed: -2,-9,-80,-7")
      end
    end

    context "with numbers larger than 1000" do
      it "ignores numbers larger than 1000" do
        post :add, params: { numbers: "2,2000,3" }, format: :json
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["result"]).to eq(5)
      end
    end
  end
end
