class PartnershipsController < ApplicationController
  def confirm
    @partnership = Partnership.find_by confirmation_token: params[:confirmation_token]

    # Only allow confirmation if token is valid, and if partnership hasn't been confirmed already.
    raise_not_found unless @partnership.present?
    raise_not_found unless @partnership.confirmed_at.nil?
  end
end
