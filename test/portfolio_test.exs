defmodule PortfolioTest do
  use ExUnit.Case

  doctest Portfolio

  describe "allocate_buys/2" do
    test "it buys" do
      assert Portfolio.allocate_buys(
               [
                 {"A", 1.0, 2, 0.5},
                 {"B", 2.0, 2, 0.5}
               ],
               5.0
             ) == {[{"A", 2, 0.5}, {"B", 1, 0.5}], 1.0}
    end

    test "if there is cash leftover, and the portfolio is perfectly allocated, it should still use it!" do
      assert Portfolio.allocate_buys(
               [
                 {"A", 1.0, 2, 1.0}
               ],
               5.0
             ) == {[{"A", 5, 1.0}], 0.0}
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
