
class RiskRowConverter < BaseRowConverter
  @model_class = :Risk

  def setup_object
    object = setup_object_by_slug(attrs)
    if !object.new_record?
      add_warning(:slug, "Risk already exists and will be updated")
    end
  end

  def reify
    handle(:slug, SlugColumnHandler)

    handle(:controls, LinkControlsHandler)
    handle(:categories, LinkCategoriesHandler,
           :scope_id => Control::CATEGORY_TYPE_ID)
    handle(:documents, LinkDocumentsHandler)

    handle(:people_responsible, LinkPeopleHandler,
           :role => :responsible)
    handle(:people_accountable, LinkPeopleHandler,
           :role => :accountable)

    handle(:systems, LinkRelationshipsHandler,
           :model_class => System,
           :relationship_type_id => :risk_is_a_threat_to_system,
           :direction => :to,
           :extra_model_where_params => { :is_biz_process => false })
    handle(:processes, LinkRelationshipsHandler,
           :model_class => System,
           :model_human_name => "Process",
           :relationship_type_id => :risk_is_a_threat_to_process,
           :direction => :to,
           :extra_model_where_params => { :is_biz_process => true })
    handle(:products, LinkRelationshipsHandler,
           :model_class => Product,
           :relationship_type_id => :risk_is_a_threat_to_product,
           :direction => :to)
    handle(:markets, LinkRelationshipsHandler,
           :model_class => Market,
           :relationship_type_id => :risk_is_a_threat_to_market,
           :direction => :to)
    handle(:data_assets, LinkRelationshipsHandler,
           :model_class => DataAsset,
           :relationship_type_id => :risk_is_a_threat_to_data_asset,
           :direction => :to)

    [:description, :likelihood, :threat_vector, :trigger, :preconditions, :impact, :inherent_risk, :risk_mitigation, :residual_risk].each do |column|
      handle_text_or_html(column)
    end

    [:financial_impact_rating, :operational_impact_rating, :reputational_impact_rating, :operational_impact_rating].each do |column|
      handle(column, RiskRatingHandler)
    end
    
    handle(:likelihood_rating, LikelihoodRatingHandler)

    [:url].each do |column|
      handle_url(column)
    end

    [:title].each do |column|
      handle_raw_attr(column)
    end
  end
end

class RiskRatingHandler < ColumnHandler
  def validate(value)
    begin
      value = value.strip.to_i
      if value < 1 || value > 5
        errors.push("must be between 1 and 5")
      end
    rescue => e
      errors.push("must be an integer between 1 and 5")
    end
  end
end

class LikelihoodRatingHandler < ColumnHandler
  def validate(value)
    begin
      if value < 0 || value > 1 || value % 0.2 != 0
        errors.push("must be between 0.2 and 1")
      end
    rescue => e
      errors.push("must be a decimal between 0.2 and 1")
    end
  end 
end

class RisksConverter < BaseConverter
  @metadata_map = Hash[*%w(Type type)]

  @object_map = Hash[*%w(
    Code slug
    Title title
    Description description
    Likelihood\ Score likelihood_rating
    Likelihood\ Description likelihood
    Threat\ Vector threat_vector
    Trigger trigger
    Pre-Conditions preconditions
    Financial\ Impact\ Score financial_impact_rating
    Operational\ Impact\ Score operational_impact_rating
    Reputational\ Impact\ Score reputational_impact_rating
    Operational\ Impact\ Score operational_impact_rating
    Impact\ Description impact
    Inherent\ Risk\ Note inherent_risk
    Risk\ Mitigation\ Note risk_mitigation
    Residual\ Risk\ Note residual_risk
    URL url
    Link:Categories categories
    Link:Controls controls
    Link:References documents
    Link:People;Responsible people_responsible
    Link:People;Accountable people_accountable
    Link:Processes processes
    Link:Systems systems
    Link:Products products
    Link:Markets markets
    Link:Assets data_assets
  )]

  @row_converter = RiskRowConverter

  def validate_metadata(attrs)
    validate_metadata_type(attrs, "Risks")
  end

  def do_export_metadata
    yield CSV.generate_line(metadata_map.keys)
    yield CSV.generate_line(["Risks"])
    yield CSV.generate_line([])
    yield CSV.generate_line([])
    yield CSV.generate_line(object_map.keys)
  end
end

