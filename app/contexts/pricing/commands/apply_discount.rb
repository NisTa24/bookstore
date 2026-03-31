module Pricing
  module Commands
    class ApplyDiscount < Shared::BaseCommand
      def call(book_id:, rule_id:)
        rule = Pricing::DiscountRule.find(rule_id)
        current_price = Pricing::Price.current_for_book(book_id).first

        unless current_price
          broadcast(:apply_discount_failed, errors: ["No current price for book #{book_id}"])
          return
        end

        money = current_price.to_money

        discounted = case rule.discount_type
        when "percentage"
          money.apply_percentage_discount(rule.value)
        when "fixed_amount"
          Pricing::ValueObjects::Money.new(
            amount_cents: [money.amount_cents - rule.value, 0].max,
            currency: money.currency
          )
        end

        event = Pricing::Events::DiscountApplied.new(
          book_id: book_id,
          original_cents: money.amount_cents,
          discounted_cents: discounted.amount_cents,
          rule_name: rule.name
        )

        log_event(:discount_applied, event)
        broadcast(:discount_applied, event)
      rescue ActiveRecord::RecordNotFound
        broadcast(:apply_discount_failed, errors: ["Discount rule not found: #{rule_id}"])
      end
    end
  end
end
