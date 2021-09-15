# -*- encoding : utf-8 -*-
require 'logger'
require 'action_mailer'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "gmail.com",
  :user_name            => "",
  :password             => "",
  :authentication       => "plain",
  :enable_starttls_auto => true
}
ActionMailer::Base.view_paths= File.dirname(__FILE__)

class TabienmongkolMailer < ActionMailer::Base

  def alert_data_email(q,e,n,p)
    puts "Sending Alert Email for #{p} email.."
    $logger.info "Sending Alert Email for #{p} email.."
    @q = q
    @n = n
    @p = p
    mail(
      :to      => [e],
      :from    => "",
      :subject => "Alert - #{p} has the quantity of #{q}"
    ) do |format|
      format.html
    end
  end
end

class TabienmongkolDatatBuilderAgent
  attr_accessor :options, :errors

  def initialize(options)
    @options = options
    @options
    create_log_file
    establish_db_connection
  end


  def create_log_file
    Dir.mkdir("#{File.dirname(__FILE__)}/logs") unless File.directory?("#{File.dirname(__FILE__)}/logs")
    $logger = Logger.new("#{File.dirname(__FILE__)}/logs/tabienmongkol_data_builder_agent.log", 'weekly')
    #~ $logger.level = Logger::DEBUG
    $logger.formatter = Logger::Formatter.new
  end

  def establish_db_connection
    # connect to the MySQL server
    get_db_connection(@options[:env])
  end

  def start_processing
    begin
      if $db_connection_established
        urls = ["http://tabienmongkol.com"]
        urls.each do |each_url|
          date_created = ((Date.today)).strftime('%Y-%m-%d')

          uri = URI.parse("http://tabienmongkol.com")
          request = Net::HTTP::Get.new(uri)
          request["Connection"] = "keep-alive"
          request["Cache-Control"] = "max-age=0"
          request["Upgrade-Insecure-Requests"] = "1"
          request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36"
          request["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
          request["Accept-Language"] = "en-US,en;q=0.9,de;q=0.8"

          req_options = {
            use_ssl: uri.scheme == "https",
            verify_mode: OpenSSL::SSL::VERIFY_NONE,
          }

          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
          end

          doc1 = Nokogiri::HTML(response.body)

          doc1.xpath("//div[@id='tb_cont']").each_with_index do |sa,i| 

              license_group = ""

              license_group = doc1.xpath("//h1")[i].text rescue ""

                sa.css('a').each do |saa|

                begin
                  
                  license_number = ""
                  price = ""
                  location = "bangkok"
                  status = ""
                  

                  price = saa.css('div')[2].text.squeeze("\n").squeeze("\t").squeeze(" ").strip rescue ""
                  license_number = saa.css('div')[0].text.squeeze("\n").squeeze("\t").squeeze(" ").strip rescue ""
                  statu = saa.css('div')[1].text.squeeze("\n").squeeze("\t").squeeze(" ").strip rescue ""
                  if statu == "จองแล้ว"
                    status = "sold"
                  else
                    status = "available"
                  end
                  
                  if saa.parent.to_s.include?"images/tabien_sp.jpg"
                    color = 'white special'
                  elsif saa.parent.to_s.include?"images/tabien_gold.jpg"
                    color = 'gold'
                  elsif saa.to_s.include?"num_style21"
                    color = 'white'
                  elsif saa.to_s.include?"num_style23"
                    color = 'blue all'
                  elsif saa.to_s.include?"num_style22"
                    color = 'green all'
                  else
                    color = ""
                  end
                  exist_data = TabienmongkolDetail.where("date_created = '#{date_created}' and license_number = '#{license_number}' and url = '#{each_url}'")

                  if exist_data.count == 0
                    $logger.info "Processing #{license_number}"
                    results = TabienmongkolDetail.create(:date_created => date_created, :url => each_url, :license_group => license_group, :license_number => license_number, :price => price, :location => location, :license_status => status, :color => color, :processing_status => '')
                  end

                    rescue Exception => e
                        $logger.error "Error Occured - #{e.message}"
                        $logger.error e.backtrace
                    end

              end

          end


        end #eachurl iteration
        update_status()
      end

    rescue Exception => e
      $logger.error "Error Occured - #{e.message}"
      $logger.error e.backtrace
      sleep 10
    ensure
      $logger.close
      #~ #Our program will automatically will close the DB connection. But even making sure for the safety purpose.
      ActiveRecord::Base.clear_active_connections!
    end
  end

  def update_status
    previous_availability_check = {}

    results5 = ActiveRecord::Base.connection.exec_query("select distinct(Concat(date_created,url)),date_created,url from tabienmongkol_details where processing_status = '' order by date_created desc ")
    results5.map{|x| previous_availability_check[x["url"].to_s] = []}

    puts  previous_availability_check
    results5.collect { |res|
      @i = 1
      @num = 31
      while @i < @num  do
        old_data = (Date.parse(res["date_created"].to_s) - @i).strftime('%Y-%m-%d')
        a = TabienmongkolDetail.where("url = '#{res["url"].to_s}' and date_created = '#{old_data}'")
        if a.count > 0
          previous_available_date = old_data
          break
        end
        @i=@i+1
      end
        # byebug
      previous_availability_check[res["url"].to_s] << {"current_date" => res["date_created"].to_s,"previous_available_date"=>previous_available_date.to_s}
    }

    previous_availability_check.each do |k,v|
      v.each do |s|
        # byebug
        puts s_current_date = (s["current_date"]).to_s
        puts  s_previous_available_date = (s["previous_available_date"]).to_s
        results = TabienmongkolDetail.where("url = '#{k}' and date_created = '#{s_previous_available_date}'")
        results.each do |res|
          license_number = res["license_number"]
          location = res["location"]
          price = res["price"]
          status = res["license_status"]
          license_group = res["license_group"]
          results_current = TabienmongkolDetail.where("url = '#{k}' and license_number = '#{license_number}' and date_created = '#{s_current_date}'")
          if results_current.count == 0
            processing_status = "Removed"
            # byebug
            TabienmongkolDetail.create(:url => k, :license_group => license_group, :license_number => license_number, :price => price, :license_status => status, :location => location, :date_created => s_current_date, :processing_status => processing_status, :price_status => '0')
          end
        end
      end
    end

    previous_status_check = {}
    results1 = ActiveRecord::Base.connection.exec_query("select distinct(Concat(date_created,url)),date_created,url from tabienmongkol_details where processing_status = '' order by date_created desc ")
    results1.map{|x| previous_status_check[x["url"].to_s] = []}
    puts  previous_status_check
    results1.collect { |res|
      @i = 1
      @num = 31
      while @i < @num  do
        old_data = (Date.parse(res["date_created"].to_s) - @i).to_s
        a = TabienmongkolDetail.where("url = '#{res["url"].to_s}' and date_created = '#{Date.parse(old_data).strftime('%Y-%m-%d')}'")
        if a.count > 0
          previous_available_date = old_data
          break
        end
        @i=@i+1
      end
      previous_status_check[res["url"].to_s] << {"current_date" => res["date_created"].to_s,"previous_available_date"=>previous_available_date.to_s}
    }

    previous_status_check.each do |k,v|
      v.each do |s|
        puts s_current_date = Date.parse(s["current_date"]).strftime('%Y-%m-%d')
        puts  s_previous_available_date =(s["previous_available_date"]).to_s

        results = TabienmongkolDetail.where("processing_status = '' and date_created = '#{s_current_date}' ")
        results.each do |res|
          id = res["id"]
          license_number = res["license_number"]
          location = res["location"]
          price = res["price"]
          status = res["license_status"]
          color = res["color"]
          license_group = res["license_group"]
          results_old = TabienmongkolDetail.where("license_number = '#{license_number}' and date_created = '#{s_previous_available_date}' and processing_status != 'Removed'")

          if results_old.count == 0
            processing_status = "New"
          else
            old_location = results_old.first["location"]
            old_price = results_old.first["price"]
            old_status = results_old.first["license_status"]
            old_color = results_old.first["color"]
            old_group = results_old.first["license_group"]
            if(old_location != location || old_price != price || old_status != status || old_color != color || old_group != license_group)
              processing_status = "Changed"
            else
              processing_status = "No Change"
            end
          end
          TabienmongkolDetail.where("id = '#{id}'").update_all(:processing_status => processing_status)
        end
      end
    end
  end
end

require 'rubygems'
require 'optparse'

options = {}
optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: ruby tabienmongkol_data_agent.rb [options]"

  # Define the options, and what they do
  options[:action] = 'start'
  opts.on( '-a', '--action ACTION', 'It can be start, stop, restart' ) do |action|
    options[:action] = action
  end

  options[:env] = 'development'
  opts.on( '-e', '--env ENVIRONMENT', 'Run the new tabienmongkol agent for building the projects' ) do |env|
    options[:env] = env
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'To get the list of available options' ) do
    puts opts
    exit
  end
end
optparse.parse!

puts @options = options
require File.expand_path('../load_configurations', __FILE__)
newprojects_agent = TabienmongkolDatatBuilderAgent.new(options)
newprojects_agent.start_processing
