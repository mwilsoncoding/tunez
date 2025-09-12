defmodule Tunez.Music.Artist do
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "artists"
    repo Tunez.Repo

    custom_indexes do
      # CREATE INDEX artists_name_gin_index ON artists USING gin(name gin_trgm_ops);
      index "name gin_trgm_ops", name: "artists_name_gin_index", using: "GIN"
    end
  end

  actions do
    defaults [:read]

    read :search do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(name, ^arg(:query)))

      pagination offset?: true, default_limit: Tunez.Constants.default_pagination_limit()

      # Putting a `load: [:aggregate_field, :calculation_field]` here will be more costly to calculate
      # since it applies to all `read`s, but ideal if the fields are always needed.
      #
      # prepare build(load: [:album_count, :latest_album_year_released, :cover_image_url])
    end

    create :create do
      accept [:name, :biography]
    end

    update :update do
      require_atomic? false

      accept [:name, :biography]

      change Tunez.Music.Changes.UpdatePreviousNames, where: [changing(:name)]
    end

    destroy :destroy do
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :previous_names, {:array, :string} do
      default []
    end

    attribute :biography, :string

    create_timestamp :inserted_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    has_many :albums, Tunez.Music.Album do
      sort year_released: :desc
    end
  end

  calculations do
    calculate :years_ago, :integer, expr(2025 - year_released)

    calculate :string_years_ago,
              :string,
              expr("wow, this was released " <> years_ago <> " years ago!")
  end

  aggregates do
    # calculate :album_count, :integer, expr(count(albums))
    count :album_count, :albums, public?: true
    # calculate :latest_album_year_released, :integer, expr(first(albums, field: :year_released))
    first :latest_album_year_released, :albums, :year_released, public?: true
    # calculate :cover_image_url, :string, expr(first(albums, field: :cover_image_url))
    first :cover_image_url, :albums, :cover_image_url
  end
end
