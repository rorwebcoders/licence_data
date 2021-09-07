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

class TabienchillMailer < ActionMailer::Base

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

class TabienchillDatatBuilderAgent
  attr_accessor :options, :errors

  def initialize(options)
    @options = options
    @options
    create_log_file
    establish_db_connection
  end


  def create_log_file
    Dir.mkdir("#{File.dirname(__FILE__)}/logs") unless File.directory?("#{File.dirname(__FILE__)}/logs")
    $logger = Logger.new("#{File.dirname(__FILE__)}/logs/tabienchill_data_builder_agent.log", 'weekly')
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
        urls = ["https://tabienchill.com/home/index.html"]
        urls.each do |each_url|
          doc = Nokogiri::HTML(RestClient.get(each_url).body)
          listings = doc.css("section.box-tabien")
          date_created = ((Date.today)).strftime('%Y-%m-%d')

          listings.each do |each_list|
            license_group = ""
            license_group = each_list.css("div.h-section").text.strip() rescue ""

            listings_1 = each_list.css("ul li")

            listings_1.each_with_index do |each_data, ind|
              begin
                status = ""
                price = ""
                location = ""
                license_number =  each_data.css("span.tabien-num").text.strip() rescue ""
                price = each_data.css("span.tabien-price").text.strip() rescue ""
                # if each_data.css("div.tabien-sum").to_s.include?("color:#F00")
                #   statu = each_data.css("div.tabien-sum").to_s.split('<span style="color:#F00">').last.split("</span>").first.strip() rescue ""
                # end

                if each_data.to_s.include?"ขายแล้ว"
                  status = "sold"
                else
                  status = "available"
                end
                
                if each_data.to_s.include?"media/license_bg/thumb/hSXkR.jpg"
                  color = "green special"
                elsif each_data.to_s.include?"media/license_bg/thumb/29568471620278476.jpg"
                  color = "blue basic"
                elsif each_data.to_s.include?"media/license_bg/thumb/q5A77.jpg"
                  color = "white special"
                elsif each_data.to_s.include?"media/license_bg/thumb/aUctm.jpg"
                  color = "white"
                elsif each_data.to_s.include?"media/license_bg/thumb/18523721602823483.jpg"
                  color = "gold"
                elsif each_data.to_s.include?"https://tabienchill.com/media/license_bg/thumb/RTGT6.jpg"
                  color = "khonkaen"
                elsif each_data.to_s.include?"https://tabienchill.com/media/license_bg/thumb/6aZfG.jpg"
                  color = "boungkarn"
                elsif each_data.to_s.include?"https://tabienchill.com/media/license_bg/thumb/MgPwJ.jpg"
                  color = "chiangrai"
                elsif each_data.to_s.include?"https://tabienchill.com/media/license_bg/thumb/xb33j.jpg"
                  color = "nakhonpathom"
                elsif each_data.to_s.include?"https://tabienchill.com/media/license_bg/thumb/c4Spy.jpg"
                  color = "nakornratchasima"
                elsif each_data.to_s.include?"https://tabienchill.com/media/license_bg/thumb/LCt9G.jpg"
                  color = "nonthaburi"
                elsif each_data.to_s.include?"https://tabienchill.com/media/license_bg/thumb/vRwtn.jpg"
                  color = "phuket"
                elsif each_data.to_s.include?"https://tabienchill.com/media/license_bg/thumb/EdGza.jpg"
                  color = 'chonburi'
                elsif each_data.to_s.include?"https://tabienchill.com/media/license_bg/thumb/3zMbY.jpg"
                  color = 'blue special'
                else
                  color = ''
                end
                  




                exist_data = TabienchillDetail.where("created_at = '#{date_created}' and license_number = '#{license_number}' and url = '#{each_url}'")

                if exist_data.count == 0
                  $logger.info "Processing #{license_number}"
                  results = TabienchillDetail.create(:date_created => date_created, :url => each_url, :license_group => license_group, :license_number => license_number, :price => price, :location => location, :license_status => status, :color => color, :processing_status => '')
                end
              rescue Exception => e
                $logger.error "Error Occured - #{e.message}"
                $logger.error e.backtrace
              end
              # break if ind >= 25
            end
            # break
          end
        end
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

    results5 = ActiveRecord::Base.connection.exec_query("select distinct(Concat(date_created,url)),date_created,url from tabienchill_details where processing_status = '' order by date_created desc ")
    results5.map{|x| previous_availability_check[x["url"].to_s] = []}

    puts  previous_availability_check
    results5.collect { |res|
      @i = 1
      @num = 31
      while @i < @num  do
        old_data = (Date.parse(res["date_created"].to_s) - @i).strftime('%Y-%m-%d')
        a = TabienchillDetail.where("url = '#{res["url"].to_s}' and date_created = '#{old_data}'")
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
        results = TabienchillDetail.where("url = '#{k}' and date_created = '#{s_previous_available_date}'")
        results.each do |res|
          license_number = res["license_number"]
          location = res["location"]
          price = res["price"]
          status = res["license_status"]
          license_group = res["license_group"]
          results_current = TabienchillDetail.where("url = '#{k}' and license_number = '#{license_number}' and date_created = '#{s_current_date}'")
          if results_current.count == 0
            processing_status = "Removed"
            # byebug
            TabienchillDetail.create(:url => k, :license_group => license_group, :license_number => license_number, :price => price, :license_status => license_status, :location => location, :date_created => date_created, :processing_status => processing_status)
          end
        end
      end
    end

    previous_status_check = {}
    results1 = ActiveRecord::Base.connection.exec_query("select distinct(Concat(date_created,url)),date_created,url from tabienchill_details where processing_status = '' order by date_created desc ")
    results1.map{|x| previous_status_check[x["url"].to_s] = []}
    puts  previous_status_check
    results1.collect { |res|
      @i = 1
      @num = 31
      while @i < @num  do
        old_data = (Date.parse(res["date_created"].to_s) - @i).to_s
        a = TabienchillDetail.where("url = '#{res["url"].to_s}' and date_created = '#{Date.parse(old_data).strftime('%Y-%m-%d')}'")
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

        results = TabienchillDetail.where("processing_status = '' and date_created = '#{s_current_date}' ")
        results.each do |res|
          id = res["id"]
          license_number = res["license_number"]
          location = res["location"]
          price = res["price"]
          status = res["license_status"]
          color = res["color"]
          license_group = res["license_group"]
          results_old = TabienchillDetail.where("license_number = '#{license_number}' and date_created = '#{s_previous_available_date}' and processing_status != 'Removed'")

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
          TabienchillDetail.where("id = '#{id}'").update_all(:processing_status => processing_status)
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
  opts.banner = "Usage: ruby tabienchill_data_agent.rb [options]"

  # Define the options, and what they do
  options[:action] = 'start'
  opts.on( '-a', '--action ACTION', 'It can be start, stop, restart' ) do |action|
    options[:action] = action
  end

  options[:env] = 'development'
  opts.on( '-e', '--env ENVIRONMENT', 'Run the new tabienchill agent for building the projects' ) do |env|
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
newprojects_agent = TabienchillDatatBuilderAgent.new(options)
newprojects_agent.start_processing
