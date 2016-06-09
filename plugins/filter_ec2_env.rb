#
# Fluentd Docker Metadata Filter Plugin - Enrich Fluentd events with Docker
# metadata
#
# Copyright 2015 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'json'

module Fluent
  class EC2InfoFilter < Fluent::Filter
    Fluent::Plugin.register_filter('ec2_env', self)

    def initialize
      super

      @ec2_info = {}
      @ec2_info["instance-id"] = ENV["EC2_INSTANCE_ID"] if env_present "EC2_INSTANCE_ID"
      @ec2_info["instance-type"] = ENV["EC2_INSTANCE_TYPE"] if env_present "EC2_INSTANCE_TYPE"
      @ec2_info["private-ip"] = ENV["EC2_PRIVATE_IP"] if env_present "EC2_PRIVATE_IP"
      @ec2_info["public-ip"] = ENV["EC2_PUBLIC_IP"] if env_present "EC2_PUBLIC_IP"
      @ec2_info["ami-id"] = ENV["EC2_AMI_ID"] if env_present "EC2_AMI_ID"
    end


    def env_present(name)
      !ENV[name].nil? and !ENV[name].empty?
    end

    def configure(conf)
      super
    end

    def filter_stream(tag, es)
      es.each { |time, record|
        record["instance-id"] = @ec2_info["instance-id"] if @ec2_info["instance-id"]
        record["ec2"] = @ec2_info if @ec2_info.length > 0
      }
      return es
    end
  end
end
