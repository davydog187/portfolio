defmodule Portfolio do
  use Ecto.Schema

  alias Portfolio.Holding

  @moduledoc """
  Portfolio contains tools for optimizing asset portfolios
  """

  embedded_schema do
    embeds_many(:holdings, Holding)
  end

  @doc """
  Returns if the portfolio's allocations matches their targets.
  A portfolio is considered balanced if each asset comes within
  1% of its target allocation.
  """
  def balanced?(holdings, percent_threshold \\ 0.01) do
    cap = value(holdings)

    Enum.all?(holdings, fn holding ->
      abs(holding.allocation_target - Holding.percentage(holding, cap)) <= percent_threshold
    end)
  end

  @doc """
  The allocation percentage of each asset in the portfolio
  """
  def allocations(holdings) do
    cap = value(holdings)

    Enum.map(holdings, fn holding ->
      {holding.name, Holding.percentage(holding, cap)}
    end)
  end

  @doc """
  Value of the portfolio (shares * price)
  """
  def value(holdings) do
    sum(holdings, &Holding.value/1)
  end

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

  @spec allocate_buys(list(Holding.t()), cash_on_hand :: float()) ::
          list({asset :: String.t(), num_shares :: integer()})

  def allocate_buys(holdings, cash_on_hand) do
    # Represents the order that we suggest to buy
    # TODO zero-ing out the shares makes everything incorrect!
    # We should instead have the existing shares, and then calculate what to buy after
    # we build the order
    order = Map.new(holdings, fn holding -> {holding.name, %Holding{holding | shares: 0}} end)

    # Asset, count and allocation
    # Cash remaining
    result = build_order(holdings, order, cash_on_hand) |> Map.values()
    cap = value(result)
    cash_remaining = cash_on_hand - cap

    holdings =
      Enum.map(result, fn holding ->
        # TODO the percentage calculation is wrong because
        # it needs to account for your existing holdings!
        {holding.name, holding.shares, Holding.percentage(holding, cap)}
      end)

    {holdings, cash_remaining}
  end

  defp build_order([], order, _cash_on_hand) do
    order
  end

  defp build_order([current | rest] = holdings, order, cash_on_hand) do
    if current.price > cash_on_hand do
      build_order(rest, order, cash_on_hand)
    else
      # Buy a share
      new_order = Map.update!(order, current.name, &Holding.inc_shares/1)

      # Potentially buy more shares
      more = build_order(holdings, new_order, cash_on_hand - current.price)

      # Don't buy a share
      dont = build_order(rest, order, cash_on_hand)

      # more goes first since if there's a tie, we want it to prefer
      # buying more shares
      Enum.min_by([more, new_order, dont], fn order ->
        order
        |> Map.values()
        |> test_statistic()
      end)
    end
  end

  @doc """
  Calculate the linear test statistic for all of the assets against their target
  allocation
  """
  @spec test_statistic(list(Holding.t())) :: float()
  def test_statistic(holdings) do
    cap = value(holdings)

    sum(holdings, fn holding ->
      :math.pow(Holding.percentage(holding, cap) - holding.allocation_target, 2)
    end)
  end

  defp sum(enumerable, func) do
    Enum.reduce(enumerable, 0.0, fn x, acc ->
      acc + func.(x)
    end)
  end
end
