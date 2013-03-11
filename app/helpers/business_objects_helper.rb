module BusinessObjectsHelper
  def related_objects(instance)
    if instance.is_a?(System) && instance.is_biz_process?
      instance.class.related_models("Process")
    else
      instance.class.related_models
    end
  end

  def arranged_related_objects(instance)
  end
end
