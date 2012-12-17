module BusinessObjectsHelper
  def related_objects(instance)
    instance.class.related_models
  end

  def arranged_related_objects(instance)
  end
end
