defmodule Portfolio.Holding do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  embedded_schema do
    field(:name, :string)
    field(:price, :float)
    field(:shares, :integer)
    field(:allocation_target, :float)
  end

  @fields [:name, :price, :shares, :allocation_target]

  def new!(name, price, shares, target) do
    %__MODULE__{}
    |> changeset(%{
      name: name,
      price: price,
      shares: shares,
      allocation_target: target
    })
    |> apply_action!(:new)
  end

  def value(%__MODULE__{price: price, shares: shares}) do
    price * shares
  end

  def inc_shares(%__MODULE__{shares: shares} = holding) do
    %__MODULE__{holding | shares: shares + 1}
  end

  @doc """
  The percentage of the portfolio this holding represents
  """
  def percentage(%__MODULE__{}, 0.0), do: 0.0

  def percentage(%__MODULE__{} = holding, portfolio_value) do
    value(holding) / portfolio_value
  end

  def changeset(data, params) do
    data
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_number(:price, greater_than: 0.0)
    |> validate_number(:shares, greater_than: 0)
    |> validate_number(:allocation_target, greater_than: 0.0, less_than_or_equal_to: 1.0)
  end
end
