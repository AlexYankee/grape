require 'spec_helper'

describe Grape::API do
  let(:combined_api) {
    UsersApi = users_api
    LocationApi = location_api
    CitiesApi = cities_api
    JobsApi = jobs_api
    Class.new(Grape::API) do
      version :v1, using: :accept_version_header, cascade: true
      mount UsersApi
      mount LocationApi
      mount CitiesApi
      mount JobsApi
    end
  }
  let(:cities_api) {
    Class.new(Grape::API) do
      namespace :cities do
        before { true }

        get do
          true
        end
      end
    end
  }

  let(:jobs_api) {
    SharedParameters = Module.new do
      extend Grape::API::Helpers

      params :pagination do
        optional :size, type: Integer, default: 20
        optional :skip, type: Integer, default: 0
      end
    end

    Class.new(Grape::API) do
      helpers SharedParameters
      namespace :jobs do
        before { true }

        params do
          requires :title, type: String
          requires :city_id, type: Integer
          optional :location, type: Hash
          requires :open_until, type: DateTime
          optional :requirement_values_attributes, type: Array do
            requires :requirement_id
            optional :float_value
            optional :integer_value
            optional :bool_value
            optional :query_options, type: Hash
            mutually_exclusive :float_value, :integer_value, :bool_value
          end
        end
        post do
          true
        end

        params do
          requires :job_id, type: String
        end
        route_param :job_id do
          before { true }
          get do
            true
          end

          delete do
            true
          end

          params do
            requires :executant_id, type: Integer
          end
          post :start do
            true
          end

          post :accept do
            true
          end

          post :reject do
            true
          end

          namespace :im do
            before { true }
            params do
              optional :user_id, type: Integer
              optional :edge_timestamp, type: DateTime
            end
            get :updates do
              true
            end

            params do
              optional :user_id, type: Integer
              optional :edge_timestamp, type: DateTime
            end
            get :history do
              true
            end

            params do
              optional :message, type: String
              optional :user_id, type: Integer
            end
            post do
              true
            end

            get :dialogs do
              true
            end
          end
        end
      end
    end
  }

  let(:users_api) {
    Class.new(Grape::API) do
      namespace :auth do
        params do
          requires :phone_number, type: String
        end
        post :access_code do
          true
        end

        params do
          requires :phone_number, type: String
          requires :access_code, type: String
          optional :device_type, type: Symbol, values: [:android, :ios]
          optional :device_token, type: String
        end
        post :access_token do
          true
        end
      end

      namespace :profile do
        before do

        end

        params do
          optional :device_type, type: Symbol, values: [:android, :ios]
          optional :device_token, type: String
        end
        get do
          true
        end

        get :requirement_values do
          true
        end

        params do
          requires :requirement_values, type: Array do
            requires :requirement_id, type: Integer
            optional :float_value, type: Float
            optional :integer_value, type: Integer
            mutually_exclusive :float_value, :integer_value
          end
        end
        post :requirement_values do
          true
        end
      end

      namespace :users do
        route_param :id do
          before { @user = true }

          get do
            true
          end
        end
      end
    end
  }

  let(:location_api) {
    Class.new(Grape::API) do
      namespace :location do
        before do
          true
        end
        params do
          requires :location, type: Hash do
            requires :longitude, type: Float
            requires :latitude, type: Float
            optional :accuracy, type: Float
          end
        end
        post do
          true
        end
      end
    end
  }

  subject {
    CombinedApi = combined_api
    Class.new(Grape::API) do
      format :json

      mount CombinedApi => '/'
    end
  }

  def app
    subject
  end

  it 'execute first request in reasonable time' do
    started = Time.now
    get '/mount1/nested/test_method'
    expect(Time.now - started).to be < 5
  end
end