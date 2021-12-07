# encoding: UTF-8
# frozen_string_literal: true

module API::V2
  module P2p
    class P2pOrders < Grape::API
      helpers ::API::V2::P2p::NamedParams

      desc 'Create P2p order',
           is_array: true,
           success: API::V2::Entities::P2pOrder
      params do
        use :p2p_order
      end
      post '/p2p_orders' do
        user_authorize! :create, ::P2pOrder
        advertis = Advertisement.find_by id: params[:advertisement_id]
        if params[:number_of_coin] > advertis.coin_avaiable
          return present "Please enter a valid amount less than the amount #{advertis.coin_avaiable}"
        end
        order = P2pOrder.create_order(params, advertis)
        order.member_id = current_user.id
        order.save
        present order, with: API::V2::Entities::P2pOrder
      end

      desc 'Edit P2p order',
           is_array: true,
           success: API::V2::Entities::P2pOrder
      params do
        use :p2p_edit
      end

      post '/p2p_order/:id' do
        order = P2pOrder.find_by id: params[:id]
        if order.blank?
          return present "Order not found"
        end
        payment_method_ids = order.advertisement.advertisement_payment_methods.pluck(:payment_method_id)
        unless payment_method_ids.include?(params[:payment_method_id])
          return present "Invalid payment method"
        end
        if order.update(params)
          present order, with: API::V2::Entities::P2pOrder
        else
          present "update fail!"
        end
      end

      desc 'List P2p order',
           is_array: true,
           success: API::V2::Entities::P2pOrder

      get '/member/p2p_orders' do
        P2pOrder.all.where(member_id: current_user.id)
      end

      desc 'Admin show list P2p order',
           is_array: true,
           success: API::V2::Entities::P2pOrder

      get '/admin/:id/p2p_orders' do
        P2pOrder.all.where(member_id: params[:member_id])
      end

      desc 'Clain P2p order',
           is_array: true,
           success: API::V2::Entities::P2pOrder
      params do
        use :p2p_claim
      end

      post '/p2p_order/:id/claim' do
        order = P2pOrder.find_by id: params[:id]
        if order.update(params)
          order.save
          return present order, with: API::V2::P2p::Entities::P2pOrderClaim
          # return present order
          # if params[:images]
          #   params[:images].each do |image|
          #     file_path = "/public/" + i[:file_name]
          #     image_path = Rails.root + file_path
          #     image_file = File.new(image_path)
          #     order.images.attach(image)
          #     order.save
          #   end
          # end
        end
      end

      desc 'Admin list clain P2pOrder',
           is_array: true,
           success: API::V2::P2p::Entities::P2pOrderClaim
      params do
        use :p2p_list_claim
      end

      get '/admin/p2p_order/claims' do
        list_order_claim = P2pOrder.request
        present list_order_claim, with: API::V2::P2p::Entities::P2pOrderClaim
      end

      desc 'Admin show clain P2pOrder',
           is_array: true,
           success: API::V2::P2p::Entities::P2pOrderClaim
      params do
        use :p2p_show_claim
      end

      get '/admin/p2p_orders/:id/claim' do
        order = P2pOrder.find_by id: params[:id]
        if order.claim_status
          present order, with: API::V2::P2p::Entities::P2pOrderClaim
        else
          return present "Claim not found!"
        end
      end
    end
  end
end
