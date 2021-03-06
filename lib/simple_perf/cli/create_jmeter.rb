require 'trollop'

module SimplePerf
  module CLI
    class CreateJmeter
      include Shared

      def execute
        opts = Trollop::options do
          version SimplePerf::VERSION
          banner <<-EOS

Creates CloudFormation stack for JMeter instances.

Usage:
      simple_perf create_jmeter -e ENVIRONMENT -p PROJECT_NAME -a AMI -i INSTANCE_TYPE -s S3_BUCKET -c COUNT
EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :project, "Project name to manage", :type => :string
          opt :ami, "AWS ami", :type => :string
          opt :instancetype, "AWS instance type", :type => :string
          opt :s3bucket, "AWS s3 bucket", :type => :string
          opt :count, "Number of JMeter instances", :type => :string
        end
        Trollop::die :environment, "is required but not specified" unless opts[:environment]
        Trollop::die :project, "is required but not specified" unless opts[:project]
        Trollop::die :ami, "is required but not specified" unless opts[:ami]
        Trollop::die :instancetype, "is required but not specified" unless opts[:instancetype]
        Trollop::die :s3bucket, "is required but not specified" unless opts[:s3bucket]
        Trollop::die :count, "is required but not specified" unless opts[:count]

        gem_root = File.expand_path '../..', __FILE__

        config = Config.new.environment opts[:environment]

        command = 'simple_deploy create' +
            ' -e ' + opts[:environment] +
            ' -n ' + 'simple-perf-' + opts[:project] +
            ' -t '+ gem_root + '/cloud_formation_templates/instance_group.json' +
            ' -a Description="EC2 JMeter Instance"' +
            ' -a KeyName=' +  config['aws_keypair'] +
            ' -a AmiId=' +  opts[:ami] +
            ' -a S3BucketName=' + opts[:s3bucket] +
            ' -a InstanceType=' + opts[:instancetype] +
            ' -a MinimumInstances=' + opts[:count] +
            ' -a MaximumInstances=' + opts[:count] +
            ' -a Abort=no'

        Shared::pretty_print `#{command}`
      end

    end
  end
end
