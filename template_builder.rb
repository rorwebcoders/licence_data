
require 'csv'
require 'nokogiri'
require 'open-uri'
require 'openssl'
require 'watir'
require 'byebug'
# require 'watir-webdriver'
require 'mysql2'

$table_name = "licence_details"


client = Mysql2::Client.new(:host => "localhost", :username => "root",:password=>"",:database=>"licence_data_development")



previous_availability_check = {}

results5 = client.query("select distinct(Concat(date_created,url)),date_created,url from licence_details where processing_status = '' order by date_created desc ")
byebug
results5.map{|x| previous_availability_check[x["url"].to_s] = []}

puts  previous_availability_check
results5.collect{|res|

  @i = 1
  @num = 31
  while @i < @num  do
      old_data = (Date.parse(res["date_created"].to_s) - @i).strftime('%Y-%m-%d')
      a = client.query("select * from licence_details where url = '#{res["url"].to_s}' and date_created = '#{old_data}'")
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
        results = client.query("select * from licence_details where url = '#{k}' and date_created = '#{s_previous_available_date}' ")
        results.each do |res|
          license_number = res["license_number"]
          location = res["location"]
          price = res["price"]
          status = res["license_status"]
          license_group = res["license_group"]
          results_current = client.query("select * from licence_details where url = '#{k}' and license_number = '#{license_number}' and date_created = '#{s_current_date}' ")
          if results_current.count == 0
            processing_status = "Removed"
            # byebug
            client.query("insert into licence_details(url,license_group,license_number,price,license_status,location,date_created,processing_status) values ('#{k}','#{license_group}','#{license_number}','#{price}','#{status}','#{location}','#{s_current_date}','#{processing_status}')")
          end
        end

      end
    end



    previous_status_check = {}
    results1 = client.query("select distinct(Concat(date_created,url)),date_created,url from licence_details where processing_status = '' order by date_created desc ")
    results1.map{|x| previous_status_check[x["url"].to_s] = []}
    puts  previous_status_check
    results1.collect{|res|

      @i = 1
      @num = 31
      while @i < @num  do
          old_data = (Date.parse(res["date_created"].to_s) - @i).to_s
          a = client.query("select * from licence_details where url = '#{res["url"].to_s}' and date_created = '#{Date.parse(old_data).strftime('%Y-%m-%d')}'")
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

            results = client.query("select * from licence_details where processing_status = '' and date_created = '#{s_current_date}' ")
            results.each do |res|
              id = res["id"]
              license_number = res["license_number"]
              location = res["location"]
              price = res["price"]
              status = res["license_status"]
              results_old = client.query("select * from licence_details where license_number = '#{license_number}' and date_created = '#{s_previous_available_date}' and processing_status != 'Removed'")

              if results_old.count == 0
                processing_status = "New"
              else
                old_location = results_old.first["location"]
                old_price = results_old.first["price"]
                old_status = results_old.first["license_status"]
                if(old_location != location || old_price != price || old_status != status)
                  processing_status = "Changed"
                else
                  processing_status = "No Change"
                end
              end
              client.query("update licence_details set processing_status = '#{processing_status}' where id = '#{id}' ")
            end
          end

        end

        distinct_process = {}
        results7 = client.query("select distinct(date_created),date_created,url from licence_details where is_duplicate is null order by date_created desc ")
        results7.map{|x| distinct_process[x["date_created"].to_s] = []}
        # byebug
        distinct_process.each  do |k,v|
          # byebug
          result10 = client.query("SELECT license_number, count(*) as cnt FROM licence_details where date_created = '#{Date.parse(k).strftime('%Y-%m-%d')}' and processing_status != 'Removed' GROUP BY license_number having cnt > 1 order by cnt desc")
          temp_1 = result10.map{|x|  x["license_number"].to_s}

          if temp_1.count > 0
            puts client.query("update licence_details set is_duplicate = 'yes' where  date_created = '#{Date.parse(k).strftime('%Y-%m-%d')}' and processing_status != 'Removed' and license_number in ('"+temp_1.join("','")+"')")
          end
          puts client.query("update licence_details set is_duplicate = 'no' where  date_created = '#{Date.parse(k).strftime('%Y-%m-%d')}' and is_duplicate is null")
        end


        puts results_csv = client.query("select url,license_number from licence_details where date_created < #{Date.today + 31  }")

        # CSV.open("licence_details_processed_results.csv", 'wb', { col_sep: '~' }) do |csv|
        #   csv << ['url', 'license_number']
        #   results_csv.each do |each_data|
        #     result_url = each_data['url']
        #     result_number = each_data['license_number']
        #     csv << [result_url, result_number]
        #   end
        # end
