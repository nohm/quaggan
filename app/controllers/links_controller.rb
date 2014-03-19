class LinksController < ApplicationController
  def create
    response = ''
    success = false

    # don't allow empty fields
    if params[:link].nil? or params[:link][:original].nil? or params[:link][:mask].nil?
      response = 'Please enter all field: link[original] and link[mask]'

    # numbers are reserved for ids
    elsif params[:link][:mask] =~ /^-?[0-9]+$/
      response = 'You can\t mask URLs with numbers!'

    # mask has to be unique, obviously
    elsif params[:link][:mask] != '' and Link.where('mask ILIKE ?', params[:link][:mask]).count != 0
      response = 'Given mask already exists!'

    # original must be a valid url
    elsif !Link.valid?(params[:link][:original])
      response = 'That ain\'t no valid URL!'

    # no matches? store it!
    else
      clean_mask = params[:link][:mask].downcase.gsub(/[^a-z0-9 ]/, '').gsub(/ /, '-')
      params[:link][:mask] = clean_mask

      @link = Link.new(params[:link].permit(:original,:mask))
      if @link.save
        success = true
        response = "#{ENV['BASE_URL']}#{@link.id}"
        # give a link to the mask if provided
        unless @link.mask.blank?
          response << "<br>#{ENV['BASE_URL']}#{@link.mask}"
        end

      else
        response = 'Error saving URL, forgot something?'

      end
    end

    respond_to do |format|
      format.js {
        render json: response.split('<br>')
      }
      format.html {
        flash[success ? :notice : :alert] = response
        redirect_to root_path
      }
    end
  end

  def show
    response = ''
    success = false

    begin
      link = Link.new
      if params[:id] =~ /^-?[0-9]+$/
        link = Link.find(params[:id]).original
      else
        link = Link.where('mask ILIKE ?', params[:id]).first.original
      end

      response = link
      success = true

    rescue
      response = "Uh oh! Link not found with id '#{params[:id]}'"
      
    end

    respond_to do |format|
      format.js { 
        render json: response
      }
      format.html {
        if success
          head :moved_permanently, :location => response
        else
          flash[:alert] = response
          redirect_to root_path
        end
      }
    end
  end
end
