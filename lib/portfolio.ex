defmodule Portfolio do
  @moduledoc """
  Portfolio contains tools for optimizing asset portfolios
  """

  @type asset ::
          {name :: String.t(), price :: float(), shares :: non_neg_integer(),
           target_alloc :: float()}

  @doc """
  Given a portfolio comprising assets, their price,
  their current shares and their target allocation, this algorithm attempts to find
  the optimal buys that will consume the cash on-hand such that the portfolio becomes
  balanced.

  # Examples

      #iex> porfolio = [
        {"A", 1.0, 2, 0.5},
        {"B", 2.0, 2, 0.5},
      ]
      #iex> allocate_buys(portfolio, 1.0)
      [{"A", 1}, {"B", 0}]


      #iex> allocate_buys(portfolio, 2.0)
      [{"A", 1}, {"B", 1}]
  """

  @spec allocate_buys(list(asset()), cash_on_hand :: float()) ::
          list({asset :: String.t(), num_shares :: integer()})

  def allocate_buys(assets, cash_on_hand) do
    # Represents the order that we suggest to buy
    order =
      Map.new(assets, fn {name, price, _shares, target} -> {name, {name, price, 0, target}} end)

    # Asset, count and allocation
    # Cash remaining
    result = build_order(assets, order, cash_on_hand) |> Map.delete(:order) |> Map.values()
    cap = sum(result, fn {_, price, shares, _} -> price * shares end)
    cash_remaining = cash_on_hand - cap

    assets =
      Enum.map(result, fn {name, price, shares, _} ->
        case cap do
          0.0 ->
            {name, shares, 0.0}

          cap ->
            {name, shares, price * shares / cap}
        end
      end)

    {assets, cash_remaining}
  end

  defp build_order([], order, _cash_on_hand) do
    order
  end

  defp build_order([{name, price, _, _} | rest] = assets, order, cash_on_hand) do
    if price > cash_on_hand do
      build_order(rest, order, cash_on_hand)
    else
      # Buy a share
      new_order =
        Map.update!(order, name, fn {_, _, shares, _} = asset ->
          put_elem(asset, 2, shares + 1)
        end)
        |> Map.put(:order, :buy)

      # Potentially buy more shares
      more = build_order(assets, new_order, cash_on_hand - price) |> Map.put(:order, :more)

      # Don't buy a share
      dont = build_order(rest, order, cash_on_hand) |> Map.put(:order, :dont)

      # more goes first since if there's a tie, we want it to prefer
      # buying more shares
      Enum.min_by([more, new_order, dont], fn order ->
        order
        |> Map.delete(:order)
        |> Map.values()
        |> test_statistic()
      end)
    end
  end

  @doc """
  Calculate the linear test statistic for all of the assets against their target
  allocation
  """
  @spec test_statistic(list(asset)) :: float()
  def test_statistic(assets) do
    cap = sum(assets, fn {_, price, shares, _} -> price * shares end)

    sum(assets, fn {_, price, shares, target} ->
      percent =
        case cap do
          0.0 ->
            0.0

          cap ->
            price * shares / cap
        end

      :math.pow(percent - target, 2)
    end)
  end

  defp sum(enumerable, func) do
    Enum.reduce(enumerable, 0.0, fn x, acc ->
      acc + func.(x)
    end)
  end
end
