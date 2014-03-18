class Link < ActiveRecord::Base
	validates :original, presence: true
end
