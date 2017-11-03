defmodule EtherscanBot.Watcher do
  use GenServer
  require Logger

  @etherscan_host "http://api.etherscan.io/api"
  @etherscan_key "E6BKZNG99NUPGNDCY5H23IRYNRW44WYJZN"
  @wallet_address "0x335b02e981d2b02696bb3db1214579ed34c6afec"
  @etherscan_params %{
    module: "account",
    action: "txlist",
    sort: "asc",
    address: @wallet_address,
    startblock: 4_000_000,
    endblock: 10_000_000,
    apikey: @etherscan_key
  }

  @mailchimp_key "6c25f62b160387f22540b7125fe7c7c4-us16"
  @mailchimp_list_id "5ff896c97c"

  @mailchimp_host "https://us16.api.mailchimp.com/3.0/lists/#{@mailchimp_list_id}/members"
  @mailchimp_auth {"etherscan_bot", @mailchimp_key}
  @mailchimp_params %{count: 100_000_000}
  # @mailchimp_fields %{
  #   "MMERGE4" => "ETH address",
  #   "MMERGE5" => "ETH amount",
  #   "MMERGE6" => "Pre-pay"
  # }

  def check do
    GenServer.cast(:watcher, :check)
  end

  def add_field(name, tag, type) do
    merge_fields_url = "https://us16.api.mailchimp.com/3.0/lists/#{@mailchimp_list_id}/merge-fields"
    HTTPotion.post(merge_fields_url, basic_auth: @mailchimp_auth, body: Poison.encode!(%{
      tag: tag,
      name: name,
      type: type
    }))
  end

  def get_transactions do
    req_txs = HTTPotion.get(@etherscan_host, query: @etherscan_params)
    {:ok, res_txs} = req_txs |> Map.get(:body) |> Poison.decode
    %{"message" => "OK", "result" => transactions, "status" => "1"} = res_txs
    transactions
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :watcher)
  end

  def init(:ok) do
    {:ok, []}
  end

  def handle_cast(:check, state) do
    Logger.info("Check phase initiated!")

    senders =
      get_transactions()
      |> Enum.reduce(%{}, fn (%{"from" => from, "to" => to, "value" => real_amount}, acc) ->
        from = String.downcase(from)
        to = String.downcase(to)
        address = @wallet_address
        case to do
          ^address -> put_in(acc[from], real_amount)
          _ -> acc
        end
      end)

    req_members = HTTPotion.get(@mailchimp_host, basic_auth: @mailchimp_auth, query: @mailchimp_params)
    {:ok, res_members} = req_members |> Map.get(:body) |> Poison.decode
    %{"members" => members} = res_members

    Enum.each(members, fn %{"id" => id, "merge_fields" => fields} ->
      user_api_addr = "#{@mailchimp_host}/#{id}"
      %{"MMERGE4" => eth_address, "MMERGE6" => pre_paid} = fields
      eth_address = String.downcase(eth_address)

      if eth_address in Map.keys(senders) && pre_paid != "YES" do
        body = Poison.encode!(%{merge_fields: %{"MMERGE6" => "YES", "R_AMOUNT" => senders[eth_address]}})
        HTTPotion.put(user_api_addr, basic_auth: @mailchimp_auth, body: body)
      end
    end)

    Logger.info("Check phase finished")

    {:noreply, state}
  end
end
