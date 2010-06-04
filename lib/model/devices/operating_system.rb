#############################################################################
# Copyright © 2009 Dan Wanek <dwanek@nd.gov>
#
#
# This file is part of Zenoss-RubyREST.
# 
# Zenoss-RubyREST is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# Zenoss-RubyREST is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with Zenoss-RubyREST.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
module Zenoss
  module Model
    class OperatingSystem
      include Zenoss
      include Zenoss::Model

      @@zenoss_methods = []
      attr_reader :interfaces

      def initialize(device)
        @device = device
        @interfaces = []
        interfaces = plist_to_array(rest("interfaces"))
        return nil if interfaces.nil?
        interfaces.each do |inf|
          @interfaces << Interface.new(@device, inf) unless inf.nil? || inf.empty?
        end # do |inf|
      end

      # In order to retrieve RRD data related to interfaces we need to define an 
      # Interface class for use by the Operating System class.
      class Interface
        include ::Zenoss
        include ::Zenoss::Model
        include ::Zenoss::Model::RRDView
        
        attr_reader :name
        
        def initialize(device, path)
          @device   = device
          if(m = /#{@device.path}\/#{@device.device}\/os\/interfaces\/([\w_\-\.]+)>/.match(path))
            @name = m[1]
          else  
            @name = nil
          end # if
          
          model_init
        end # initialize
        
        #
        # TBD
        def ips
          @ips ||= plist_to_array(rest("getIpAddresses")) 
        end # ip
        
        #
        # TBD
        def mac
          @mac ||= rest("getInterfaceMacaddress")
        end # mac

        private 

        def rest(method)
          return nil if @name.nil? || @name.empty?
          super("#{@device.path}/#{@device.device}/os/interfaces/#{@name}/#{method}")
        end # rest
      end # Interface
      
      
      
      private

      def rest(method)
        super("#{@device.path}/#{@device.device}/os/#{method}")
      end

    end # OperatingSystem
  end # Model
end # Zenoss
