defmodule Tunez.Music do
  use Ash.Domain,
    otp_app: :tunez,
    extensions: [AshJsonApi.Domain, AshPhoenix]

  forms do
    form :create_album, args: [:artist_id]
  end

  resources do
    resource Tunez.Music.Artist do
      define :create_artist, action: :create
      define :read_artists, action: :read

      define :search_artists,
        action: :search,
        args: [:query],
        # Putting a `load: [:aggregate_field, :calculation_field]` here is a middle-ground solution
        # that puts the cost of calculating those fields in the caller's hands. By using the code
        # interface for the domain, these options are set. They can instead construct a query manually
        # to avoid doing the calculations.
        default_options: [load: [:album_count, :latest_album_year_released, :cover_image_url]]

      define :get_artist_by_id, action: :read, get_by: :id
      define :update_artist, action: :update
      define :destroy_artist, action: :destroy
    end

    resource Tunez.Music.Album do
      define :create_album, action: :create
      define :get_album_by_id, action: :read, get_by: :id
      define :update_album, action: :update
      define :destroy_album, action: :destroy
    end
  end
end
