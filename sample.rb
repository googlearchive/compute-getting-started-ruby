require 'google/api_client'
require 'highline/import'
require './oauth_util'

# Specify your project id here.
project = 'YOUR_PROJECT_ID'

# Constants for use as request parameters.
BASE_URL = 'https://www.googleapis.com/compute/v1beta12/projects/'
API_VERSION = 'v1beta13'
DEFAULT_PROJECT = project
GOOGLE_PROJECT = 'google'
DEFAULT_INSTANCE_NAME = 'new-node-ruby'
DEFAULT_IMAGE = BASE_URL + GOOGLE_PROJECT + '/images/ubuntu-12-04-v20120912'
DEFAULT_ZONE = BASE_URL + DEFAULT_PROJECT + '/zones/us-east1-a'
DEFAULT_MACHINE = BASE_URL + DEFAULT_PROJECT + '/machine-types/n1-standard-1'
DEFAULT_NETWORK = BASE_URL + DEFAULT_PROJECT + '/networks/default'

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
  '2' => compute.operations.list,
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
    'project' => DEFAULT_PROJECT
  },
  compute.operations.list => {
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
    'project' => DEFAULT_PROJECT
  },
  compute.instances.insert => {
    'project' => DEFAULT_PROJECT,
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
  print "[2] List Operations \n"
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
