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

module Fluent
  class DockerGelfMetadataFilter < Fluent::Filter
    Fluent::Plugin.register_filter('docker_gelf_metadata', self)

    def initialize
      super

      require 'json'
    end

    def configure(conf)
      super

      @labels = ENV["LABELS"] ? ENV["LABELS"].split(',') : []
      @options = ENV["LOGSTASH_OPTS"] ? JSON.parse(ENV["LOGSTASH_OPTS"]) : {}
    end

    def build_logstash_opts(container_opts)
      opts = container_opts ? JSON.parse(container_opts) : {}
      @options.each do |k, v|
        opts[k] = v unless container_opts and container_opts[k]
      end
      opts.length > 0 ? opts : nil
    end

    def filter_stream(tag, es)
      new_es = MultiEventStream.new

      es.each { |time, record|
        image_parts = record['_image_name'].split(':')
        logstash_opts = build_logstash_opts record['_LOGSTASH_OPTS']
        image_labels = {}
        @labels.each { |l| image_labels[l] = record["_#{l}"] if record["_#{l}"]}
        new_record = {
          'docker' => {
            'cid' => record['_container_id'],
            'name' => record['_container_name'],
            'image' => record['_image_name'],
            'image_tag' => image_parts.length > 1 ? image_parts[1] : "",
            'image_id' => record['_image_id'],
            'created' => record['_created'],
            'docker_host' => record['host'],
            'args' => record['_command']
          },
          'message' => record["short_message"],
          '@timestamp' => Time.now.to_datetime.rfc3339(9)
        }
        new_record['labels'] = image_labels if image_labels.length > 0
        new_record["options"] = logstash_opts if logstash_opts
        new_es.add(time, new_record)
      }

      return new_es
    end
  end
end
