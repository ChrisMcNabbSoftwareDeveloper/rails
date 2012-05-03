module ActionController
  module Head
    extend ActiveSupport::Concern

    # Return a response that has no content (merely headers). The options
    # argument is interpreted to be a hash of header names and values.
    # This allows you to easily return a response that consists only of
    # significant headers:
    #
    #   head :created, :location => person_path(@person)
    #
    #   head :created, :location => @person
    #
    # It can also be used to return exceptional conditions:
    #
    #   return head(:method_not_allowed) unless request.post?
    #   return head(:bad_request) unless valid_request?
    #   render
    def head(status, options = {})
      options, status = status, nil if status.is_a?(Hash)
      status ||= options.delete(:status) || :ok
      location = options.delete(:location)

      options.each do |key, value|
        headers[key.to_s.dasherize.split('-').each { |v| v[0] = v[0].chr.upcase }.join('-')] = value.to_s
      end

      self.status = status
      self.location = url_for(location) if location

      if include_content_type?(self.status)
        self.content_type = Mime[formats.first] if formats
      else
        headers.delete('Content-Type')
      end

      self.response_body = " "
    end

    private
    # :nodoc:
    def include_content_type?(status)
      case status
      when 100..199
        false
      when 204, 205, 304
        false
      else
        true
      end
    end
  end
end
