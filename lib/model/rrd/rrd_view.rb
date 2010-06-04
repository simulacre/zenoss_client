# 
#
# rrd_view
# 2010-06-04 09:45:33
# Caleb Crane <caleb.crane@kvh-ms.com>

# Add in methods that for retrieving information about RRD files, etc.,.
module Zenoss
  module Model
    
    # Download the Zenoss API documentation (http://community.zenoss.org/community/documentation/official_documentation/api) 
    # and review Products.ZenModel.RRDView.RRDView-class.html
    module RRDView
      
      def get_rrd_filename(dsname)
        custom_rest("getRRDFileName?dsname=#{dsname}")
      end
      
      def get_rrd_value(dsname)
        custom_rest("getRRDValue?dsname=#{dsname}")
      end
      
      def get_rrd_template_name
        rest("getRRDTemplateName")
      end
      
      def get_rrd_templates
        rest("getRRDTemplates")
      end
      
      def rrd_path
        rest("rrdPath")
      end
      
      def full_rrd_path
        custom_rest("fullRRDPath")
      end
      
      def get_default_graph_defs
        rest("getDefaultGraphDefs")
      end
      
      def get_rrd_names
        plist_to_array(custom_rest("getRRDNames"))
      end
      
      def get_rrd_paths
        plist_to_array(custom_rest("getRRDPaths"))
      end
      
    end # RRDView

    
  end # Model
end # Zenoss