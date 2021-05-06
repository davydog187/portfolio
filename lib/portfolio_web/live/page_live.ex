defmodule PortfolioWeb.PageLive do
  use PortfolioWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, assets: [])}
  end

  @impl true
  def handle_event("rebalance", params, socket) do
    IO.inspect(params, label: "rebalance")
    {:noreply, socket}
  end

  @impl true
  def handle_event("add-asset", _, socket) do
    assets = socket.assigns.assets
    new = {"", 0.0, 0, 0.0}
    {:noreply, assign(socket, :assets, [new | assets])}
  end
end
