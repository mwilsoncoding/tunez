defmodule Tunez.Music.Artist do
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "artists"
    repo Tunez.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:name, :biography]
    end

    update :update do
      require_atomic? false

      accept [:name, :biography]

      change fn changeset, _context ->
               new_name = Ash.Changeset.get_attribute(changeset, :name)
               previous_name = Ash.Changeset.get_data(changeset, :name)
               previous_names = Ash.Changeset.get_data(changeset, :previous_names)

               names =
                 [previous_name | previous_names]
                 |> Stream.uniq()
                 |> Enum.reject(fn name -> name == new_name end)

               Ash.Changeset.change_attribute(changeset, :previous_names, names)
             end,
             where: [changing(:name)]
    end

    destroy :destroy do
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, do: allow_nil?(false)

    attribute :previous_names, {:array, :string} do
      default []
    end

    attribute :biography, :string

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :albums, Tunez.Music.Album do
      sort year_released: :desc
    end
  end
end
