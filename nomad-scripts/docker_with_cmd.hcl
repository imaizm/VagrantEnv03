# There can only be a single job definition per file.
# Create a job with ID and Name 'example'
job "example" {
	# Run the job in the global region, which is the default.
	# region = "global"

	# Specify the datacenters within the region this job can run in.
	datacenters = ["dc1"]

	# Service type jobs optimize for long-lived services. This is
	# the default but we can change to batch for short-lived tasks.
	# type = "service"

	# Priority controls our access to resources and scheduling priority.
	# This can be 1 to 100, inclusively, and defaults to 50.
	# priority = 50

	# Restrict our job to only linux. We can specify multiple
	# constraints as needed.
	constraint {
		attribute = "$attr.kernel.name"
		value = "linux"
	}

	# Configure the job to do rolling updates
	update {
		# Stagger updates every 10 seconds
		stagger = "10s"

		# Update a single task at a time
		max_parallel = 1
	}

	group "web" {
		count = 2

		task "httpd" {
			# Use Docker to run the task.
			driver = "docker"

			# Configure Docker driver with the image
			config {
				image = "imaizm/web-front:0.1_with_cmd"
				port_map {
					http = 80
					consul01 = 8300
					consul02 = 8301
					consul03 = 8302
					consul04 = 8400
					consul05 = 8500
					consul06 = 8600
				}
			}

			service {
				port = "http"
				check {
					type = "http"
					path = "/"
					interval = "10s"
					timeout = "2s"
				}
			}

			# We must specify the resources required for
			# this task to ensure it runs on a machine with
			# enough capacity.
			resources {
				cpu = 500 # 500 Mhz
				memory = 128 # 128 MB
				network {
					mbits = 10
					port "http" {
					}
				}
			}
		}
	}
}
