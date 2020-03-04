class SoundController < ApplicationController
  before_action :authenticate_admin!

  def index
    unless params[:request].nil?
      if check.valid?
        conversion
      else
        error_info
      end
    end
  end

  def conversion
    audio_format = TtsConversion.index(client, synthesis_input, voice, audio_config, params[:codec])
    success_info(audio_format)
  end

  def client
    Google::Cloud::TextToSpeech.new
  end

  def synthesis_input
    { params[:text_or_ssml] => params[:request] }
  end

  def voice
    { language_code: params[:lang], name: params[:voicename] }
  end

  def audio_config
    { audio_encoding: params[:codec] }
  end

  def check
    Validation.new(form_params)
  end

  def success_info(audio_format)
    flash[:success] = "<a href='/output/output.#{audio_format}' download>Download #{audio_format}</a>".html_safe
  end

  def error_info
    flash[:error] = 'Invalid request format'
  end

  private

  def form_params
    params.permit(:request)
  end
end
