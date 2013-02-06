require 'google/api_client'
require 'highline/import'
require './oauth_util'

# Specify your project id here.
project = 'YOUR_PROJECT_ID'

# Constants for use as request parameters.
BASE_URL = 'https://www.googleapis.com/compute/v1beta14/projects/'
API_VERSION = 'v1beta14'
DEFAULT_PROJECT = project
GOOGLE_PROJECT = 'google'
DEFAULT_INSTANCE_NAME = 'new-node-ruby'
DEFAULT_IMAGE = BASE_URL + GOOGLE_PROJECT + '/global/images/gcel-12-04-v20130104'
DEFAULT_ZONE_NAME = 'us-east1-a'
DEFAULT_ZONE = BASE_URL + DEFAULT_PROJECT + '/global/zones/' + DEFAULT_ZONE_NAME
DEFAULT_MACHINE = BASE_URL + DEFAULT_PROJECT + '/global/machineTypes/n1-standard-1'
DEFAULT_NETWORK = BASE_URL + DEFAULT_PROJECT + '/global/networks/default'

# Creating a new API client and loading the Google Compute Engine API.
client = Google::APIClient.new
compute = client.discovered_api('compute', API_VERSION)

# OAuth authentication.
auth_util = CommandLineOAuthHelper.new(
  'https://www.googleapis.com/auth/compute')
client.authorization = auth_util.authorize()

# Linking each input selection to an API request.
api_request_selection_map = {
  '1' => compute.instances.list,
  '2' => compute.global_operations.list,
  '3' => compute.zones.list,
  '4' => compute.machine_types.list,
  '5' => compute.images.list,
  '6' => compute.networks.list,
  '7' => compute.instances.get,
  '8' => compute.instances.insert
}

# Linking each API request to appropriate request parameters.
api_request_parameter_map = {
  compute.instances.list => {
    'project' => DEFAULT_PROJECT,
    'zone' => DEFAULT_ZONE_NAME
  },
  compute.global_operations.list => {
    'project' => DEFAULT_PROJECT
  },
  compute.zones.list => {
    'project' => DEFAULT_PROJECT
  },
  compute.machine_types.list => {
    'project' => GOOGLE_PROJECT
  },
  compute.images.list => {
    'project' => GOOGLE_PROJECT
  },
  compute.networks.list => {
    'project' => DEFAULT_PROJECT
  },
  compute.instances.get => {
    'instance' => DEFAULT_INSTANCE_NAME,
    'project' => DEFAULT_PROJECT,
    'zone' => DEFAULT_ZONE_NAME
  },
  compute.instances.insert => {
    'project' => DEFAULT_PROJECT,
    'zone' => DEFAULT_ZONE_NAME
  }
}

# Linking each API request to an appropriate request body.
api_request_body_map = {
  compute.instances.insert => {
    'name'  => DEFAULT_INSTANCE_NAME,
    'image' => DEFAULT_IMAGE,
    'zone'  => DEFAULT_ZONE,
    'machineType' => DEFAULT_MACHINE,
    'networkInterfaces' => [{ 'network' => DEFAULT_NETWORK }]
  }
}

# REPL style interface for making API requests.
while true
  print "[1] List Instances \n"
  print "[2] List Global Operations \n"
  print "[3] List Zones \n"
  print "[4] List Machine Types \n"
  print "[5] List Images \n"
  print "[6] List Networks \n"
  print "[7] Get An Example Instance \n"
  print "[8] Insert An Example Instance \n"
  print "Press any other key to exit \n"
  print "\n"
  api_selection = ask "Please select an API request from the above list. \n"
  print "\n \n"
  case api_selection
  when '1'..'8'
    api_request = api_request_selection_map[api_selection]

    # Executing the selected API request, passing along an appropriate set of
    # request parameters and a request body.
    result = client.execute(
      :api_method => api_request,
      :parameters => api_request_parameter_map[api_request],
      :body_object => api_request_body_map[api_request]
    )

    print result.body
  else
    print 'Not a valid selection, please run program again and select a valid' +
    " API request. \n"
    exit
  end
end
