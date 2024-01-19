class PagesController < ApplicationController
  def index
  end

  def product
  end

  def parse_site
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

    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.proxy = proxy.selenium_proxy

    options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
    options.profile = profile

    driver = Selenium::WebDriver.for :firefox, options: options
    driver.manage.timeouts.page_load = 10

    begin
      driver.navigate.to params[:url]
    rescue Selenium::WebDriver::Error::TimeoutError
      puts "Navigation timed out"
    rescue Net::ReadTimeout
      puts "The operation timed out"
    end

    sleep(1)

    begin
      title = driver.find_element(:class_name, 'product-title-container')
      seller = driver.find_element(:class_name, 'company-name')
      attributes = driver.find_element(:class_name, 'attribute-list')
      price = driver.find_element(:class_name, 'price')
    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts "Element not found"
    end

    begin
      image_element = driver.find_element(:class_name, 'detail-main-img')
      image_src = image_element.attribute('src')
    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts "Image element not found"
    end

    @title = title.text
    @slller = seller.text
    @attributes = attributes.text
    @price = price.text
    @image_src = image_src

    driver.quit
    proxy.close
    server.stop

    puts "=" * 100
    puts "#{@title}, #{@slller}, #{@attributes}, #{@price}"

    render :index
  end
end
