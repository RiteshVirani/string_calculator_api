class CalculatorController < ApplicationController
  def add
    numbers = params[:numbers]
    delimiter = extract_delimiter(numbers)
    numbers = extract_numbers(numbers, delimiter)
    sum = calculate_sum(numbers)
    render json: { result: sum }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def extract_delimiter(numbers)
    delimiter_match = numbers.match(/^\/\/(.*)\n/)
    delimiter_match ? delimiter_match[1] : ',|\n'
  end

  def extract_numbers(numbers, delimiter)
    numbers_without_delimiter = numbers.gsub(/^\/\/(.*)\n/, '')
    numbers_without_delimiter.split(/#{delimiter}|\\n|;/).reject(&:empty?).map(&:to_i).tap do |nums|
      raise "Invalid input" if numbers_without_delimiter.end_with?("#{delimiter}") || numbers_without_delimiter.end_with?("\\n")
    end
  end

  def calculate_sum(numbers)
    negatives = numbers.select { |n| n < 0 }
    raise "Negative numbers not allowed: #{negatives.join(',')}" if negatives.any?

    valid_numbers = numbers.reject { |n| n > 1000 }
    valid_numbers.sum
  end
end
