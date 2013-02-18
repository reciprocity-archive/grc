require 'spec_helper'

def clean_attributes(attributes)
  attributes.delete("crypted_password")
  attributes
end

describe PaperTrail do
  context 'deleting objects' do
    models = ActiveRecord::Base.connection.tables.collect{|t| t.underscore.singularize}
    models.delete("schema_migration")
    models.delete("version")

    models.each do |model|
      it "should log deletion of object #{model.camelize}" do
        record = FactoryGirl.create(model.to_sym)
        record.destroy
        d = Version.find_by_item_id_and_item_type(record.id, model.camelize).reify
        d.live?.should == false
        clean_attributes(d.attributes).should == clean_attributes(record.attributes)
      end
    end

    it "should log deletion of categorizables" do
      control = FactoryGirl.create(:control)
      category = FactoryGirl.create(:category)
      czn = category.categorizations.create(:categorizable => control)
      control.destroy
      category.categorizations.count.should == 0

      czn1 = Version.find_by_item_id_and_item_type(czn.id, "Categorization").reify

      czn1.live?.should == false
      czn1.category_id.should == category.id
      czn1.categorizable_id.should == control.id
    end

    it "should log deletion of documentables" do
      control = FactoryGirl.create(:control)
      document = FactoryGirl.create(:document)
      od = document.object_documents.create(:documentable => control)
      control.destroy
      document.object_documents.count.should == 0

      od1 = Version.find_by_item_id_and_item_type(od.id, "ObjectDocument").reify

      od1.live?.should == false
      od1.document_id.should == document.id
      od1.documentable_id.should == control.id
    end

    it "should log deletion of personables" do
      control = FactoryGirl.create(:control)
      person = FactoryGirl.create(:person)
      op = person.object_people.create(:personable => control)
      op.role = 'default'
      op.save
      control.destroy

      person.object_people.count.should == 0

      op1 = Version.find_by_item_id_and_item_type(op.id, "ObjectPerson").reify

      op1.live?.should be_false
      op1.person_id.should == person.id
      op1.personable_id.should == control.id
    end

    it "should log deletion of dependent relationships" do
      directive = FactoryGirl.create(:directive)
      product = FactoryGirl.create(:product)
      maker_of = FactoryGirl.create(:relationship_type, :relationship_type => 'maker_of',
                                :description => 'The source is the maker of the destination',
                                :forward_phrase => 'is the maker of',
                                :backward_phrase => 'is made by')
      rel = FactoryGirl.create(:relationship, :source => directive, :destination => product, :relationship_type_id => 'maker_of')
      directive.destroy
      product.destination_relationships.count.should eq(0)
      rel1 = Version.find_by_item_id_and_item_type(rel.id, "Relationship").reify
      rel1.live?.should be_false
      rel1.source_id.should eq(directive.id)
      rel1.destination_id.should eq(product.id)
    end
  end
end
