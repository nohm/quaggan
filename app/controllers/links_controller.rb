class LinksController < ApplicationController
  def index
    @link = Link.new
  end

  def create
    response = ''
    status = :created
    success = false

    # don't allow empty fields
    if params[:link].nil? or params[:link][:original].nil? or params[:link][:mask].nil?
      response = 'Please enter all fields: link[original] and link[mask]'
      status = :bad_request

    # numbers are reserved for ids
    elsif params[:link][:mask] =~ /^-?[0-9]+$/
      response = 'You can\t mask URLs with numbers!'
      status = :bad_request

    # mask has to be unique, obviously
    elsif params[:link][:mask] != '' and Link.where('mask ILIKE ?', params[:link][:mask]).count != 0
      response = 'Given mask already exists!'
      status = :not_acceptable

    # original must be a valid url
    elsif !Link.valid?(params[:link][:original])
      response = 'That ain\'t no valid URL!'
      status = :bad_request

    # no matches? store it!
    else
      clean_mask = params[:link][:mask].downcase.gsub(/[^a-z0-9- ]/, '').gsub(/ /, '-')
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
        status = :bad_request

      end
    end

    respond_to do |format|
      format.js {
        render json: response.split('<br>'), status: status
      }
      format.html {
        flash[success ? :notice : :alert] = response
        redirect_to root_path
      }
    end
  end

  def show
    response = ''
    status = :found
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
      status = :not_found

    end

    respond_to do |format|
      format.js { 
        render json: response, status: status
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
