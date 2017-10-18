# EtherscanBot

Monitoring tool

## Installation
  * Install [elixir](https://elixir-lang.org/install.html)
      * Ubuntu 16.04
      * Load latest erlang repos `wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb`
      * Update packages list `sudo apt update`
      * Install Erlang deps `sudo apt install esl-erlang`
      * Install Elixir `sudo apt install elixir`
  * Install dependencies with `mix do deps.get, deps.compile`
  * Start foreground application with `mix run -e EtherscanBot.start`
  * Start background application with `elixir --detached -S mix run -e EtherscanBot.start`
