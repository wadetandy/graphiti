# frozen_string_literal: true
module Graphiti
  class Resource
    module Interface
      extend ActiveSupport::Concern

      class_methods do
        def all(params = {}, base_scope = nil)
          validate!(params)
          _all(params, {}, base_scope)
        end

        # @api private
        def _all(params, opts, base_scope)
          runner = Runner.new(self, params, opts.delete(:query), :all)
          opts[:params] = params
          runner.proxy(base_scope, opts)
        end

        def find(params = {}, base_scope = nil)
          validate!(params)
          _find(params, base_scope)
        end

        # @api private
        def _find(params = {}, base_scope = nil)
          guard_nil_id!(params[:data])
          guard_nil_id!(params)

          id = params[:data].try(:[], :id) || params.delete(:id)
          params[:filter] ||= {}
          params[:filter][:id] = id if id

          runner = Runner.new(self, params, nil, :find)
          runner.proxy base_scope,
            single: true,
            raise_on_missing: true,
            bypass_required_filters: true
        end

        def build(params, base_scope = nil)
          validate!(params)
          runner = Runner.new(self, params)
          runner.proxy(base_scope, single: true, raise_on_missing: true)
        end

        private

        def validate!(params)
          return if Graphiti.context[:graphql] || !validate_endpoints?

          if context&.respond_to?(:request)
            path = context.request.env["PATH_INFO"]
            unless allow_request?(path, params, context_namespace)
              raise Errors::InvalidEndpoint.new(self, path, context_namespace)
            end
          end
        end

        def guard_nil_id!(params)
          return unless params
          if params.key?(:id) && params[:id].nil?
            raise Errors::UndefinedIDLookup.new(self)
          end
        end
      end
    end
  end
end
