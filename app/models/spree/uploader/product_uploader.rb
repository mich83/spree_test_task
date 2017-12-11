# implementation of uploader class for products
class Spree::Uploader::ProductUploader < Spree::Uploader::BaseUploader
  include Spree::Uploader::Parser
  mime 'text/plain' => :csv  # define mime type and corresponding helper
  model :product # define Spree model

  # convert hash from csv file to attributes structure
  def attributes(record)
    {
        # attributes of product
        name: record['name'],
        description: record['description'],
        slug: record['slug'],
        available_on: parse_datetime(record['availability_date']),
        shipping_category: default_shipping_category,
        price: parse_float(record['price']),
        # stock quantity
        master_attributes: stock_attributes(record['stock_total'])
    }.merge(classifications(record['category']))
  end

  def classifications(name)
    taxon = find_taxon(name)
    taxon ? { classifications_attributes: [{ taxon: taxon }] } : {}
  end

  def stock_attributes(stock_total)
    if stock_total
      {
          stock_items_attributes: [{
                                 stock_location: default_location,
                                 count_on_hand: stock_total
                             }]
      }
    else
      {}
    end
  end

  # default stock location. For this task let's use one with name "default"
  def default_location
    @default_location ||= Spree::StockLocation.find_by_name('default')
  end

  # default shipping category. For this task let's use one with name "default"
  def default_shipping_category
    @default_shipping_category ||= Spree::ShippingCategory.find_by_name('Default')
  end

  # creates or finds taxonomy
  def category_taxonomy
    @category_taxonomy ||= Spree::Taxonomy.find_or_create_by(name: 'Category')
  end

  def find_taxon(name)
    return if name.blank?  # if name is not specified there is no need to create taxon
    @taxons ||= {} # cache initialization if necessary
    @taxons[name] ||= Spree::Taxon.find_by(name: name, taxonomy: category_taxonomy) || create_taxon(name) # find or create in database
  end

  def create_taxon(name)
    root_taxon = category_taxonomy.taxons.where(depth: 0).first
    Spree::Taxon.create(name: name, parent: root_taxon, taxonomy: category_taxonomy)
  end
end