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
      assets = [
        {"A", 1.0, 1, 1 / 6},
        {"B", 2.0, 1, 2 / 6},
        {"C", 3.0, 1, 3 / 6}
      ]

      assert Portfolio.balanced?(assets)

      assert Portfolio.allocate_buys(assets, 1.0) ==
               {[{"A", 0, 0.0}, {"B", 0, 0.0}, {"C", 0, 0.0}], 1.0}

      assert Portfolio.allocate_buys(assets, 2.0) ==
               {[{"A", 0, 0.0}, {"B", 0, 0.0}, {"C", 0, 0.0}], 2.0}

      assert Portfolio.allocate_buys(assets, 3.0) ==
               {[{"A", 1, 0.3333333333333333}, {"B", 1, 0.6666666666666666}, {"C", 0, 0.0}], 0.0}

      assert Portfolio.allocate_buys(assets, 4.0) ==
               {[{"A", 1, 0.25}, {"B", 0, 0.0}, {"C", 1, 0.75}], 0.0}
    end

    test "real example" do
      assets = [
        {"SCHB", 96.1825, 4, 0.4},
        {"SCHG", 128.8067, 3, 0.3},
        {"SCHF", 37.875, 8, 0.2},
        {"SCHE", 32.03, 4, 0.1}
      ]

      assert Portfolio.value(assets) == 1202.2701000000002
      refute Portfolio.balanced?(assets)

      assert Portfolio.allocations(assets) ==
               [
                 {"SCHB", 0.3200029677191506},
                 {"SCHG", 0.32140872504439727},
                 {"SCHF", 0.2520232350451034},
                 {"SCHE", 0.10656507219134867}
               ]

      assert Portfolio.allocate_buys(assets, 517.92) ==
               {[
                  {"SCHB", 2, 0.4172942223086079},
                  {"SCHE", 2, 0.1389643016197823},
                  {"SCHF", 2, 0.16432322584605852},
                  {"SCHG", 1, 0.2794182502255512}
                ], 56.93829999999991}
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
