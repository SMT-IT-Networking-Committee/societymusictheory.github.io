module SMT
  module AuthorsFilter
    def pretty_authors (arr)
      formatted_auths = []

      arr.each do |auth|
        formatted_auths << "#{auth['name']} (#{auth['institution']})"
      end
      formatted_auths
    end
  end
end

Liquid::Template.register_filter(SMT::AuthorsFilter)
