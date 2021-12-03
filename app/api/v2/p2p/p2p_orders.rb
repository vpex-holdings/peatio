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
        order = P2pOrder.create_order(params)
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
        if order.update(params)
          present :success
        else
          present "update fail!"
        end
      end

      desc 'Show P2p order',
             is_array: true,
             success: API::V2::Entities::P2pOrder
      get '/p2p_order/:id' do
        order = P2pOrder.find_by id: params[:id]
        unless order
          return present 'id not found!'
        end
        present order, with: API::V2::Entities::P2pOrder
      end

    end
  end
end
