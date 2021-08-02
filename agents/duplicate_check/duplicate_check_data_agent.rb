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

class DuplicateCheckMailer < ActionMailer::Base

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

class DuplicateCheckDatatBuilderAgent
  attr_accessor :options, :errors

  def initialize(options)
    @options = options
    @options
    create_log_file
    establish_db_connection
  end


  def create_log_file
    Dir.mkdir("#{File.dirname(__FILE__)}/logs") unless File.directory?("#{File.dirname(__FILE__)}/logs")
    $logger = Logger.new("#{File.dirname(__FILE__)}/logs/duplicate_check_data_builder_agent.log", 'weekly')
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
        DuplicateTemp.delete_all
        insert_data_to_temp()
        # byebug
         distinct_process = {}
          results7 = ActiveRecord::Base.connection.exec_query("select distinct(date_created),date_created,url from duplicate_temps where is_duplicate is null order by date_created desc ")
          results7.map{|x| distinct_process[x["date_created"].to_s] = []}
          # byebug
          distinct_process.each  do |k,v|
            # byebug
            result10 = ActiveRecord::Base.connection.exec_query("SELECT license_number, count(*) as cnt FROM duplicate_temps where date_created = '#{Date.parse(k).strftime('%Y-%m-%d')}' and processing_status != 'Removed' GROUP BY license_number having cnt > 1 order by cnt desc")
            temp_1 = result10.map{|x|  x["license_number"].to_s}

            if temp_1.count > 0
              puts ActiveRecord::Base.connection.exec_query("update duplicate_temps set is_duplicate = 'yes' where  date_created = '#{Date.parse(k).strftime('%Y-%m-%d')}' and processing_status != 'Removed' and license_number in ('"+temp_1.join("','")+"')")
            end
            puts ActiveRecord::Base.connection.exec_query("update duplicate_temps set is_duplicate = 'no' where  date_created = '#{Date.parse(k).strftime('%Y-%m-%d')}' and is_duplicate is null")
          end

          update_pricing()
          update_main_table()
          write_date_to_file()
          # puts results_csv = ActiveRecord::Base.connection.exec_query("select url,license_number from duplicate_temps where date_created < #{Date.today + 31  }")
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

  def insert_data_to_temp
    $logger.info "Inserting Data to temp table"
    all_tables = $site_details["all_models"]
    all_tables.each do |each_table|
      table_data = each_table.camelize.constantize.all
      table_data.each do |each_data|
        url_temp = each_data['url']
        date_created_temp = each_data['date_created']
        license_group_temp = each_data['license_group']
        license_number_temp = each_data['license_number']
        price_temp = each_data['price']
        location_temp = each_data['location']
        license_status_temp = each_data['license_status']
        color_temp = each_data['color']
        processing_status_temp = each_data['processing_status']
        DuplicateTemp.create(:date_created => date_created_temp, :url => url_temp, :license_group => license_group_temp, :license_number => license_number_temp, :price => price_temp, :location => location_temp, :license_status => license_status_temp, :color => color_temp, :processing_status => processing_status_temp)
      end
    end
  end

  def update_main_table
    $logger.info "Updating main tables"
    all_tables = $site_details["all_models"]
    all_tables.each do |each_table|
      table_data = each_table.camelize.constantize.all
      table_data.each do |each_data|
        url_temps = each_data['url']
        license_number_temps = each_data['license_number']
        date_created_temps = each_data['date_created']
        temp_data = DuplicateTemp.where("url = '#{url_temps}' and license_number = '#{license_number_temps}' and date_created = '#{date_created_temps}'")
        each_table.camelize.constantize.where("url = '#{url_temps}' and license_number = '#{license_number_temps}' and date_created = '#{date_created_temps}'").update_all(:is_duplicate => temp_data.first.is_duplicate, :price_status => temp_data.first.price_status)
      end
    end
  end

  def update_pricing()
    $logger.info "Updating Pricing status"
    all_data = DuplicateTemp.where("is_duplicate = 'yes'")
    all_data.each do |each_data|
      t_license_number = each_data['license_number']
      t_date_created = each_data['date_created']
      t_url = each_data['url']
      d = DuplicateTemp.where("license_number = '#{t_license_number}' and price_status is null and date_created = '#{t_date_created}'")
      if d.count > 0
      puts t_license_number
      min_data = d.map {|d| d['price'].gsub(',', '')}.min
        cheapest_data = d.select {|d| d['price'].gsub(',', '')}.select {|e| e.price.gsub(',', '') == min_data}.first
        d.each do |each_d|
          if(each_d['license_number'] == cheapest_data.license_number && each_d['id'] == cheapest_data.id && each_d['url'] == cheapest_data.url)
            price_status = 'Cheapest'
          else
            price_status = '0'
          end
          DuplicateTemp.where("license_number = '#{each_d['license_number']}' and date_created = '#{each_d['date_created']}' and url = '#{each_d['url']}'").update_all(:price_status => price_status)
        end
      end
    end
    DuplicateTemp.where("is_duplicate = 'no'").update_all(:price_status => '0')
  end

  def write_date_to_file
    $logger.info "Writing data to file"
    all_tables = $site_details["all_models"]
    file_name = "License_Data_Report_#{(Date.today).strftime('%d-%m-%Y')}"
    Dir.mkdir("#{File.dirname(__FILE__)}/duplicate_check_data") unless File.directory?("#{File.dirname(__FILE__)}/duplicate_check_data")
    # CSV.open("#{File.dirname(__FILE__)}/duplicate_check_data/#{file_name}.csv", "wb") do |csv|
      workbook = WriteXLSX.new("#{File.dirname(__FILE__)}/duplicate_check_data/#{file_name}.xlsx")
        worksheet = workbook.add_worksheet
        worksheet.set_column('A:J', 20)
        format = workbook.add_format
        format.set_bold
        format.set_align('center')
      header_arr = ['URL', 'Date Created', 'License Group', 'License Number', 'Price', 'Location', 'License Status', 'Color', 'Processing Status', 'Is Duplicate', 'Price Status']
      worksheet.write(0, 0, header_arr, format)
      counter_row = 1
      all_tables.each do |each_table|
        table_data = each_table.camelize.constantize.where("date_created > ?", 2.days.ago).order('date_created DESC')
        table_data.each do |each_data|
          url_temp1 = each_data['url']
          date_created_temp1 = each_data['date_created']
          license_group_temp1 = each_data['license_group']
          license_number_temp1 = each_data['license_number']
          price_temp1 = each_data['price']
          location_temp1 = each_data['location']
          license_status_temp1 = each_data['license_status']
          color_temp1 = each_data['color']
          processing_status_temp1 = each_data['processing_status']
          is_duplicate_temp1 = each_data['is_duplicate']
          price_status_temp1 = each_data['price_status']
          data_arr = [url_temp1, date_created_temp1, license_group_temp1, license_number_temp1, price_temp1, location_temp1, license_status_temp1, color_temp1, processing_status_temp1, is_duplicate_temp1, price_status_temp1]
          worksheet.write(counter_row, 0, data_arr)
          counter_row += 1
        end
      end
    # end
    workbook.close
  end
end

require 'rubygems'
require 'optparse'

options = {}
optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: ruby duplicate_check_data_agent.rb [options]"

  # Define the options, and what they do
  options[:action] = 'start'
  opts.on( '-a', '--action ACTION', 'It can be start, stop, restart' ) do |action|
    options[:action] = action
  end

  options[:env] = 'development'
  opts.on( '-e', '--env ENVIRONMENT', 'Run the new duplicate_check agent for building the projects' ) do |env|
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
newprojects_agent = DuplicateCheckDatatBuilderAgent.new(options)
newprojects_agent.start_processing
