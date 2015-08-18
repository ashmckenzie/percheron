module Percheron
  class Unit
    module ImageHelper
      def image_name
        '%s:%s' % [ image_repo, image_version.to_s ] if image_repo && image_version
      end

      def image_repo
        if !buildable?
          unit_config.docker_image.split(':')[0]
        elsif pseudo?
          pseudo_full_name
        else
          full_name
        end
      end

      def image_version
        if buildable?
          unit_config.version
        elsif !unit_config.docker_image.nil?
          unit_config.docker_image.split(':')[1] || 'latest'
        else
          fail Errors::UnitInvalid, 'Cannot determine image version'
        end
      end

      def image_exists?
        image.nil? ? false : true
      end
    end
  end
end
