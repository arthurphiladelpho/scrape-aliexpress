require 'open-uri'
require 'nokogiri'
require 'csv'

# Grab html content and convert it into a Nokogiri HTML Document object.
def scrape(url)
  # Grab html string.
  html_string = open(url).read
  # Convert html string into a Nokogiri HTML object.
  nokogiri_html_doc = Nokogiri::HTML(html_string)
  return nokogiri_html_doc
end

# Given an Aliexpress products result page, grab all the product's urls.
def scrape_urls(nokogiri_html_doc)
  # Create an array of urls.
  urls = []
  # Search html object for the products's links.
  nokogiri_html_doc.search('a.product').each do |element|
    urls << element.attribute('href').value
  end
  return urls
end

# Go into each url and grab essential information.
def scrape_product(url)
  # Grab Nokogiri HTML object.
  nokogiri_html_doc = scrape(url)
  # Set empty strings.
  title, orders_count, rating, votes_count, price = ''
  # Search html object for the title.
  nokogiri_html_doc.search('h1.product-name').each do |element|
    title = element.text.strip
  end
  # Search html object for the orders.
  nokogiri_html_doc.search('span.order-num').each do |element|
    orders_count = element.text.strip
    if orders_count[-1] == 'o'
      orders_count.slice!(" pedido")
    else
      orders_count.slice!(" pedidos")
    end
    orders_count = Integer(orders_count)
  end
  # Search html object for the rating.
  nokogiri_html_doc.search('span.percent-num').each do |element|
    rating = element.text.strip
    rating = rating.to_f
  end
  # Search html object for the votes_count.
  nokogiri_html_doc.search('span.rantings-num').each do |element|
    votes_count = element.text.strip
    votes_count.slice!("(")
    votes_count.slice!(" votos)")
    votes_count = Integer(votes_count)
  end
  # Search html object for the price.
  nokogiri_html_doc.search('div.p-price-content span.p-price').each do |element|
    price = element.text.strip
  end

  # Create product object.
  product = Hash.new
  product[:title] = title
  product[:orders_count] = orders_count
  product[:rating] = rating
  product[:votes_count] = votes_count
  product[:url] = url
  product[:price] = price
  return product
end

# Grab a list of urls.
def get_list_of_urls(url)
  # belts_url = "https://pt.aliexpress.com/category/201005182/yoga-belts.html?site=bra&g=y&needQuery=n&isrefine=y"
  html_doc = scrape(url)
  arr_of_urls = scrape_urls(html_doc)
  arr_of_urls.map! do |url|
    'https:' + url
  end
end

# Get information about a bunch of products.
def scrape_list_of_products(list, results)
  list.each do |item|
    values = []
    product = scrape_product(item)
    product.each do |key, value|
      values << value
    end
    results << values
  end
end

# Export products to .csv file.
def write_csv(csv_file_name, products)
  csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
  CSV.open(csv_file_name, 'wb', csv_options) do |csv|
    csv << ['Title', 'Orders Count', 'Rating', 'Votes Count', 'Url', 'Price']
    products.each do |values|
      csv << values
    end
  end
end

# Grab and export products to .csv file.
def get_products(url, csv_file_name)
  url_list = get_list_of_urls(url)
  product_list = Array.new
  scrape_list_of_products(url_list, product_list)
  write_csv(csv_file_name, product_list)
  p csv_file_name + ' exported successfully.'
end

urls_and_csvs = [
  # belts
  ['https://pt.aliexpress.com/category/201005182/yoga-belts.html?isrefine=y&site=bra&g=y&needQuery=n&tag=', 'belts.csv'],
  ['https://pt.aliexpress.com/category/201005182/yoga-belts/2.html?isrefine=y&site=bra&g=y&needQuery=n&tag=', 'belts.csv'],
  # blocks
  ['https://pt.aliexpress.com/category/201005181/yoga-blocks.html?site=bra&g=y&needQuery=n&isrefine=y', 'blocks.csv'],
  ['https://pt.aliexpress.com/category/201005181/yoga-blocks/2.html?isrefine=y&site=bra&g=y&needQuery=n&tag=', 'blocks.csv'],
  ['https://pt.aliexpress.com/category/201005181/yoga-blocks/3.html?isrefine=y&site=bra&g=y&needQuery=n&tag=', 'blocks.csv'],
  # mats
  ['https://pt.aliexpress.com/category/201005176/yoga-mats.html?site=bra&g=y&needQuery=n&isrefine=y', 'mats.csv'],
  ['https://pt.aliexpress.com/category/201005176/yoga-mats/2.html?isrefine=y&site=bra&g=y&needQuery=n&tag=', 'mats.csv'],
  # blankets
  ['https://pt.aliexpress.com/category/201005184/yoga-blankets.html?isrefine=y&site=bra&g=y&needQuery=n&tag=', 'blankets.csv'],
  # circles
  ['https://pt.aliexpress.com/category/201005179/yoga-circles.html?site=bra&g=y&needQuery=n&tag=', 'circles.csv'],
  ['https://pt.aliexpress.com/category/201005179/yoga-circles/2.html?site=bra&g=y&needQuery=n&tag=', 'circles.csv']
]

urls_and_csvs.each do |page|
  get_products(page[0], page[1])
end

puts 'Scrape was successful.'

# Add price
# div.p-price-content span.p-price

  # Price min
  # span.p-price span:nth-of-type(1)
  # Price max
  # span.p-price span:nth-of-type(2)
