defmodule PortfolioTest do
  use ExUnit.Case

  doctest Portfolio

  describe "allocate_buys/2" do
    test "when the portfolio starts unbalanced" do
      assets = [
        {"A", 1.0, 2, 0.5},
        {"B", 2.0, 2, 0.5}
      ]

      refute Portfolio.balanced?(assets)
      assert Portfolio.allocate_buys(assets, 5.0) == {[{"A", 2, 0.5}, {"B", 1, 0.5}], 1.0}
    end

    test "when the portfolio starts balanced" do
      # TODO
    end

    test "if there is cash leftover, and the portfolio is perfectly allocated, it should still use it!" do
      assets = [
        {"A", 1.0, 2, 1.0}
      ]

      assert Portfolio.balanced?(assets)
      assert Portfolio.allocate_buys(assets, 5.0) == {[{"A", 5, 1.0}], 0.0}
    end
  end

  describe "test_statistic/1" do
    test "calculates the linear test statistic from the allocation and target allocation" do
      assert Portfolio.test_statistic([
               {"A", 1.0, 2, 0.5},
               {"B", 1.0, 2, 0.5}
             ]) == 0.0

      assert Portfolio.test_statistic([
               {"A", 1.0, 2, 0.8},
               {"B", 1.0, 2, 0.2}
             ]) == 0.18000000000000002

      assert Portfolio.test_statistic([
               {"A", 1.0, 2, 0.55},
               {"B", 1.0, 2, 0.45}
             ]) <
               Portfolio.test_statistic([
                 {"A", 1.0, 2, 0.8},
                 {"B", 1.0, 2, 0.2}
               ])
    end
  end
end
