class ApiController < ApplicationController
  def execute
    command = params[:command]
    arguments = params.fetch(:args).permit!.to_h.deep_symbolize_keys rescue {}

    return head(:not_found) unless respond_to?(command)

    public_send(command, **arguments)
  end

  def reaction(id:)
    flash[:action] = id
    
    redirect_to '/'
  end

  def source(*)
    render(plain: File.read(__FILE__))
  end
end
