class Link < ActiveRecord::Base
	validates :original, presence: true
	validates :mask, presence: true
end
