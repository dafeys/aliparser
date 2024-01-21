# app/services/page_parser_service.rb
class PageParserService
  def initialize(url, rate)
    @url = url
    @rate = rate
  end

  def call
    server, proxy = setup_server_and_proxy
    driver = setup_driver(proxy)

    begin
      driver.navigate.to @url
    rescue Selenium::WebDriver::Error::TimeoutError, Net::ReadTimeout
      puts "Navigation timed out"
    end

    sleep(1)

    data = parse_page(driver)

    driver.quit
    proxy.close
    server.stop

    data
  end

  private

  def setup_server_and_proxy
    server = BrowserMob::Proxy::Server.new(File.expand_path('~/Temp/browsermob-proxy-2.1.4/bin/browsermob-proxy'))
    server.start

    proxy = server.create_proxy
    proxy.headers({
                    'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64; rv:121.0) Gecko/20100101 Firefox/121.0',
                    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
                    'Accept-Language' => 'en-US,en;q=0.5',
                    'Accept-Encoding' => 'gzip, deflate, br',
                    'Connection' => 'keep-alive',
                    'Cookie' => '__wpkreporterwid_=06cee9b3-4400-469a-bd7d-68d272b449ca; ali_apache_id=33.3.38.254.1705628794904.398775.0; XSRF-TOKEN=424abd84-4102-4fc2-bd3c-9cf73d086854; ug_se_c=free_1705628799104; JSESSIONID=2C5BA125603A933B23EE14757C3D0F19; xman_us_f=x_l=0; acs_usuc_t=acs_rt=a50fb1e1bbdd45a1a42ed1661613d246; xman_t=50rXpEZGkt3gUdDiMhalIjRpmYEPF8hZeex2PaR5qMvBJBQi5n1ayXxJRbilnh05; xman_f=B2rIN5TPiRHx+K21Wz9yHA1rwK0UOeMbUKtoZKXGKmgmDRszEw/X71hNByqWrhgjGtyQbnXB0kkATySfsvaqPgNFujpQIlK/5s6xh51HllUKbFXTJTClBg==; _csrf_token=1705628797182; ali_apache_track=""; ali_apache_tracktmp=""; cookie2=abcb60fa6850ee76355d952f2b30680a; icbu_s_tag=0_2_11; t=0e45b263656dfae4bbf52ef9c82a0086; _tb_token_=f35e763e31d3b; _m_h5_tk=949c91030c495a8ca3238edb49ed5ac1_1705630868743; _m_h5_tk_enc=0a64a01be6e1a9ad8d6863af43a286fc; isg=BOLiX07x85QcOO_IiJSVADykMGFEM-ZNmQ32mCx6T9Ui_4B5FMDQX409K6MDdF7l; tfstk=eruezR1nPiQ18wfjYl4zbpR8YKrLlrpXE4w7ZbcuOJ2hRw6obYMiOQKp2zoZEAEQKzZSU7ljeaZHeBFuzvMgK937RQ7rZYzSAX0JzTkLQWIBvYTzZXwZJJgrwaPoZYdLFBds9XU8rK9XhEGK9CDVK18jfpj7gzvXhFTj9XU8rDGgHFSbyy1eJgZVnj2i70wLKQTJPRblr2qLY87YB5FZ7WEUnEelrkgaTkymTgWhe5Aw94nFEgqhP5yX_CSWbSjX0x4jxgI8vBFahBCd2gE365yX_CSR2knY_-Od9'
                  })

    [server, proxy]
  end

  def setup_driver(proxy)
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.proxy = proxy.selenium_proxy

    options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
    options.profile = profile

    driver = Selenium::WebDriver.for :firefox, options: options
    driver.manage.timeouts.page_load = 3

    driver
  end

  def parse_page(driver)
    EasyTranslate.api_key = ENV['GOOGLE_TRANSLATE_API_KEY']

    data = {}
    @price_data = []

    begin
      data[:title] = translate(driver.find_element(:class_name, 'product-title-container').text)
      data[:seller] = driver.find_element(:class_name, 'company-name').text
      data[:attributes] = translate(driver.find_element(:class_name, 'attribute-list').text)
      data[:seller] = driver.find_element(:class_name, 'company-name').text
      data[:price] = driver.find_element(:class_name, 'price').text
      data[:image_src] = driver.find_element(:class_name, 'detail-main-img').attribute('src')
      data[:price_items] = driver.find_elements(:class, 'price-item')
    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts "Element not found"
    end

    data[:price_data] = []

    data[:price_items].each do |item|
      quality = item.find_element(:class, 'quality').text
      price = item.find_element(:class, 'price').text

      price = price.gsub('$', '').to_f

      converted_price = (price * @rate.to_f).round(2)

      data[:price_data] << { quality: quality, price: converted_price }
    end

    data[:price_data].each do |item|
      puts "Quality: #{item[:quality]}, Price: #{item[:price]}"
    end

    price = data[:price].gsub(/[$\/pair]/, '').to_f
    data[:converted_price] = price * @rate.to_f

    data
  end

  def translate(text)
    EasyTranslate.translate(text, to: :uk)
  end
end
