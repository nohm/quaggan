class LinksController < ApplicationController
  def create

  	# numbers are reserved for ids
  	if params[:link][:mask] =~ /^-?[0-9]+$/
  		flash["alert mask_is_num"] = 'You can\t mask URLs with numbers!'
  		redirect_to root_path

  	# mask has to be unique, obviously
  	elsif Link.where('mask ILIKE ?', params[:link][:mask]).count != 0
  		flash["alert mask_is_duplicate"] = 'This mask alreay exists!'
  		redirect_to root_path

    # no matches? store it!
  	else
  		clean_mask = params[:link][:mask].downcase.gsub(/[^a-z0-9 ]/, '').gsub(/ /, '-')
  		params[:link][:mask] = clean_mask

  		@link = Link.new(params[:link].permit(:original,:mask))
	    if @link.save
	      flash["notice link_id"] = "#{ENV['BASE_URL']}#{@link.id}"
	      # give a link to the mask if provided
	      unless @link.mask.blank?
	      	flash["notice link_mask"] = "#{ENV['BASE_URL']}#{@link.mask}"
	      end

	      redirect_to root_path

	    else
  		  flash["alert save_error"] = 'Error saving URL, forgot something?'
	      redirect_to root_path
	    end
  	end
  end

  def show
  	begin
	  	link = Link.new
	  	if params[:id] =~ /^-?[0-9]+$/
	  		link = Link.find(params[:id])
	  	else
	  		link = Link.where('mask ILIKE ?', params[:id]).first
	  	end

	  	head :moved_permanently, :location => link.original

	rescue
		flash["alert unknown_id"] = "Uh oh! Link not found with id '#{params[:id]}'"
		redirect_to root_path
	end
  end
end
