module Graphiti
  class Serializer < JSONAPI::Serializable::Resource
    include Graphiti::Extensions::BooleanAttribute
    include Graphiti::Extensions::ExtraAttribute
    include Graphiti::SerializableHash
    prepend Graphiti::SerializableTempId

    # Keep track of what attributes have been applied by the Resource,
    # via .attribute, and which have been applied by a custom serializer
    # class/file.
    # This way, we can ensure attributes NOT applied by a resource still
    # go through type checking/coercion
    class_attribute :attributes_applied_via_resource
    class_attribute :extra_attributes_applied_via_resource
    self.attributes_applied_via_resource = []
    self.extra_attributes_applied_via_resource = []

    def self.inherited(klass)
      super
      klass.class_eval do
        extend JSONAPI::Serializable::Resource::ConditionalFields
      end
    end

    # Temporary fix until fixed upstream
    # https://github.com/jsonapi-rb/jsonapi-serializable/pull/102
    def requested_relationships(fields)
      @_relationships
    end

    # Allow access to resource methods
    def method_missing(id, *args, &blk)
      if @resource.respond_to?(id, true)
        @resource.send(id, *args, &blk)
      else
        super
      end
    end
  end
end
