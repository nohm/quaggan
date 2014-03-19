class Link < ActiveRecord::Base
	validates :original, presence: true

	def self.valid?(url)
	  uri = URI.parse(url)
	  %w( http https ).include?(uri.scheme)
	rescue URI::BadURIError
	  false
	rescue URI::InvalidURIError
	  false
	end
end
