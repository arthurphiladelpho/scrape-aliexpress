require 'open-uri'
require 'nokogiri'

# The scrape method:
# will grab html content and convert it into a Nokogiri HTML Document object.
def scrape(url)
  # Grab html string.
  html_string = open(url).read
  # Convert html string into a Nokogiri HTML object.
  nokogiri_html_doc = Nokogiri::HTML(html_string)
  return nokogiri_html_doc
end

# The scrape_urls method:
# Given an Aliexpress products result page,
# it will grab all the product's urls.
def scrape_urls(nokogiri_html_doc)
  # Create an array of urls.
  urls = []
  # Search html object for the products's links.
  nokogiri_html_doc.search('a.product').each do |element|
    urls << element.attribute('href').value
  end
  return urls
end

# Grab a list of urls.
belts_url = "https://pt.aliexpress.com/category/201005182/yoga-belts.html?site=bra&g=y&needQuery=n&isrefine=y"
belts_html_doc = scrape(belts_url)
belts_urls = scrape_urls(belts_html_doc)
# Loop over array of urls and run method to grab the data we want.

single_product_url = "https://pt.aliexpress.com/item/New-Arrival-Fitness-Exercise-Gym-Yoga-Stretch-Strap-Belt-Figure-Waist-Leg-Yoga-Stretch-SA785-P40/32781467407.html?spm=a2g03.search0103.3.1.17a61a1emjOfgy&ws_ab_test=searchweb0_0,searchweb201602_2_10065_10068_318_10547_319_5727315_10548_10696_450_10084_10083_10618_452_535_534_533_10307_532_5727215_204_10059_10884_10887_100031_320_10103_448_449,searchweb201603_60,ppcSwitch_0&algo_expid=9b496794-5bfa-4067-916d-7dbaaa1b1169-0&algo_pvid=9b496794-5bfa-4067-916d-7dbaaa1b1169&transAbTest=ae803_4&priceBeautifyAB=0"

# Go into each url and grab essential information.
def scrape_product(url)
  # Grab Nokogiri HTML object.
  nokogiri_html_doc = scrape(url)
  # Set empty strings.
  title, orders_count, rating, votes_count = ''
  # Search html object for the title.
  nokogiri_html_doc.search('h1.product-name').each do |element|
    title = element.text.strip
  end
  # Search html object for the orders.
  nokogiri_html_doc.search('span.order-num').each do |element|
    orders_count = element.text.strip
    orders_count.slice!(" pedidos")
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
  # Create product object.
  product = Hash.new
  product[:title] = title
  product[:orders_count] = orders_count
  product[:rating] = rating
  product[:votes_count] = votes_count
  return product
end

# products = belts_urls.each_with_index { |item, index|
#   p scrape_product(item)
#   break
# }
p scrape_product(single_product_url)


# Next up:
# votes_count
