# -*- encoding : utf-8 -*-
require 'rubygems'
require 'logger'
require 'active_record'
require 'optparse'
require 'nokogiri'
require 'watir'
require 'mysql2'
require 'csv'
require 'headless'
require 'net/ftp'
require 'simple_xlsx_reader'
require 'write_xlsx'



ActiveRecord::Base.default_timezone = :utc
require File.expand_path('../../lib/config/database_connection', __FILE__)
puts require File.expand_path('../../../config/application', __FILE__)
require File.expand_path('../../lib/models/tabieninfinity_detail', __FILE__)
require File.expand_path('../../lib/models/duplicate_temp', __FILE__)
require File.expand_path('../../lib/models/tabien9_detail', __FILE__)
require File.expand_path('../../lib/models/kaitabien_detail', __FILE__)
require File.expand_path('../../lib/models/lekpramool_detail', __FILE__)
require File.expand_path('../../lib/models/tabien999_detail', __FILE__)
require File.expand_path('../../lib/models/tabiend789_detail', __FILE__)
require File.expand_path('../../lib/models/tabienrodnamchock_detail', __FILE__)
require File.expand_path('../../lib/models/teeneetabien_detail', __FILE__)
# require File.expand_path('../../lib/models/markettabien_detail', __FILE__)
# require File.expand_path('../../lib/models/tabienrodvip_detail', __FILE__)
# require File.expand_path('../../lib/models/buddytabien_detail', __FILE__)
# require File.expand_path('../../lib/models/tabienhot_detail', __FILE__)
# require File.expand_path('../../lib/models/booktabien_detail', __FILE__)
# require File.expand_path('../../lib/models/ttabien_detail', __FILE__)
# require File.expand_path('../../lib/models/thetabienvip_detail', __FILE__)
# require File.expand_path('../../lib/models/attabien_detail', __FILE__)
require File.expand_path('../../lib/models/raktabien_detail', __FILE__)
# require File.expand_path('../../lib/models/tabienmotorcycle_detail', __FILE__)
# require File.expand_path('../../lib/models/tabienchill_detail', __FILE__)
# require File.expand_path('../../lib/models/tabienrodpramool_detail', __FILE__)
# require File.expand_path('../../lib/models/buddytabien_detail', __FILE__)
#~ puts require File.expand_path('../../../config/boot', __FILE__)
#~ require File.expand_path('../../lib/config/*