# frozen_string_literal: true
class Graphiti::Adapters::ActiveRecord::BelongsToSideload < Graphiti::Sideload::BelongsTo
  include Graphiti::Adapters::ActiveRecord::Inference

  def default_base_scope
    resource_class.model.all
  end

  def scope(parent_ids)
    base_scope.where(primary_key => parent_ids)
  end
end
