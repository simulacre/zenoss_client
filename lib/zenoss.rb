#############################################################################
# Copyright © 2010 Dan Wanek <dwanek@nd.gov>
#
#
# This file is part of zenoss_client.
# 
# zenoss_client is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# zenoss_client is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with zenoss_client.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
require 'rubygems'
require 'date'
require 'tzinfo'
require 'uri'

module Zenoss

  # Set the Base URI of the Zenoss server
  #
  # @param [URI, String] uri is the URL we use to connect to the Zenoss server
  # @return [URI] the URI that was parsed and used as our base connection
  def Zenoss.uri(uri)
    if(uri.kind_of?(URI))
      uri.path << '/' unless(uri.path.index(/\/$/))
      const_set(:BASE_URI, uri)
    else
      uri << '/' unless(uri.index(/\/$/))
      const_set(:BASE_URI, URI.parse(uri))
    end
  end

  # @param [String] user
  # @param [String] pass
  # @return [Boolean]
  def Zenoss.set_auth(user, pass)
    const_set(:USER, user)
    const_set(:PASS, pass)
    true
  end

  # @return [Model::DeviceClass] the base DeviceClass /zport/dmd/Devices
  def Zenoss.devices
    Model::DeviceClass.new('/zport/dmd/Devices')
  end

  # @return [Model::ServiceOrganizer] the base ServiceOrganizer /zport/dmd/Services
  def Zenoss.services
    Model::ServiceOrganizer.new('/zport/dmd/Services')
  end

  # @return [Model::System] the base System /zport/dmd/Systems
  def Zenoss.systems
    Model::System.new('/zport/dmd/Systems')
  end

  #
  # Allow the caller to execute REST requests that don't
  # yet have zenoss_client wrappers
  #
  # Example: 
  #    device.os.interfaces.each { |inf| puts "  #{inf.getInterfaceMacaddress}" }
  def method_missing(name, *args, &block)
    rest("#{name}")
  end # method_missing(name, args*, &block)

  private

  # Prepend the appropriate path and call the REST method on the URL set with Zenoss#uri
  #
  # @param [String] req_path the request path of the REST method
  # @return [String] the response body of the REST call
  def rest(req_path)
    Net::HTTP.start(Zenoss::BASE_URI.host,Zenoss::BASE_URI.port) {|http|
      req = Net::HTTP::Get.new("#{BASE_URI.path}#{req_path}")
      req.basic_auth USER, PASS if USER
      response = http.request(req)
      response.body.chomp! unless response.body.nil?
      return(response.body)
    }
  end

  # Call a custom Zope method to work around some issues of unsupported or bad behaving
  # REST methods.
  # @see http://gist.github.com/343627 for more info.
  #
  # @param [String] req_path the request path of the REST method ( as if it wasn't misbehaving )
  #   @example req_path
  #     getRRDValues?dsnames=['ProcessorTotalUserTime_ProcessorTotalUserTime','MemoryPagesOutputSec_MemoryPagesOutputSec']
  # @return [String] the response body of the REST call
  def custom_rest(req_path)
    meth,args = req_path.split('?')
    meth = "callZenossMethod?methodName=#{meth}"
    unless args.nil?
      meth << '&args=['
      # Remove the named parameters because we can't dynamically call named parameters in Python.
      # This method uses positional parameters via the passed Array (Python List).
      args.split('&').inject(nil) do |delim,arg|
        meth << "#{delim}#{arg.split('=').last}"
        delim = ',' if delim.nil?
      end
      meth << ']'
    end
    rest(meth)
  end

  # Some of the REST methods return Strings that are formated like a Python list.
  # This method turns that String into a Ruby Array.
  # If the list parameter is nil the return value is also nil.
  #
  # @param [String] list a Python formatted list
  # @return [Array,nil] a bonafide Ruby Array
  def plist_to_array(list)
    return nil if list.nil?
    list = sanitize_str(list)
    (list.gsub(/[\[\]]/,'')).split(/,\s+/)
  end

  # Converts a String formatted like a Python Dictionary to a Ruby Hash.
  #
  # @param [String] dict a Python dictionary
  # @return [Hash,nil] a Ruby Hash
  def pdict_to_hash(dict)
    return nil if dict.nil?
    puts "Dict: #{dict}"
    dict = sanitize_str(dict)
    puts "New Dict: #{dict}"
    dict = dict.sub(/^\{(.*)\}$/,'\1').split(/[,:]/).map do |str|
      str.strip
    end
    Hash[*dict]
  end

  # Converts a String in Python's DateTime format to Ruby's DateTime format
  # If the pdt parameter is nil the return value is also nil.
  #
  # @param [String] pdt a String formatted in Python's DateTime format
  # @return [DateTime] a bonafide Ruby DateTime object
  def pdatetime_to_datetime(pdt)
    return nil if pdt.nil?
    pdt = pdt.split(/\s+/)
    tz = TZInfo::Timezone.get(pdt.last)
    DateTime.strptime("#{pdt[0]} #{pdt[1]} #{tz.current_period.abbreviation.to_s}", '%Y/%m/%d %H:%M:%S.%N %Z')
  end

  # Do some clean-up on the string returned from REST calls.  Removes some
  # quote characters embedded in the string and other misc.
  #
  # @param [String] str string returned from REST call
  # @return [String] sanitized string
  def sanitize_str(str)
    str.gsub(/['"]/,'')
  end

end # Zenoss

require 'model/model'