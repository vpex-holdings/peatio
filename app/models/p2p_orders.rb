# frozen_string_literal: true

class P2pOrder < ApplicationRecord
  belongs_to :advertisement
  belongs_to :payment_method
  belongs_to :advertisement_payment_methods
  has_many_attached :images

  enum status: [:ordered, :paid, :complete, :cancel]
  enum p2p_orders_type: [:sell, :buy]
  enum claim_status: [:request, :approve, :canceled]

  def self.create_order(params, advertis)
    order = new(params)
    order.price = advertis.price
    order.ammount = order.number_of_coin * order.price
    order.order_number = SecureRandom.hex(6)
    if order.save
      account = advertis.creator.accounts.where(currency_id: advertis.currency_id).first
      account.lock_funds(order.number_of_coin)
    end
    order
  end
end
