defmodule EtherscanBot do
  require Logger

  def start do
    Logger.info("Application started...")
    monitor()
  end

  def monitor do
    EtherscanBot.Watcher.check
    :timer.sleep(60 * 1000 * 5)
    monitor()
  end
end
