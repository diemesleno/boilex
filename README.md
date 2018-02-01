# Boilex

Boilex is mix task to generate Elixir project development tools configuration boilerplate.

## Installation

Add the following parameters to `deps` function in `mix.exs` file

```
{:boilex, github: "tim2CF/boilex", only: [:dev, :test], runtime: false},
```

## Usage

### boilex.init

Command `mix boilex.init` generates development tools configuration files in already existing Elixir project. It can be used with any **Elixir** or **Phoenix** application except *umbrella* projects. To generate configuration execute this command and follow instructions.

```
cd ./myproject
mix deps.get && mix compile
mix boilex.init
```

- `Coveralls` tool will help you to check test coverage for each module of new project. Can be configured with `coveralls.json` file. It's recommended to keep minimal test coverage = 100%.
- `Dialyzer` is static analysis tool for BEAM bytecode. Most useful feature of this tool is perfect type inference what will work in your project from-the-box without writing any explicit function specs or any other overhead. Can be configured with `.dialyzer_ignore` file.
- `ExDoc` is a tool to generate beautiful documentation for your Elixir projects.
- `Credo` static code analysis tool will make your code pretty and consistent. Can be configured with `.credo.exs` file.
- `scripts` directory contains auto-generated bash helper scripts.

### boilex.ci

Some mix tasks are made to use by CI. But of course tasks can be executed locally if needed. List of tasks:

```
mix help | grep "boilex\.ci"
```

### scripts

- `.env` text file contains variables are required by some scripts and mix tasks.
- `start.sh` locally starts compiled application.
- `pre-commit.sh` is git pre-commit hook. This script will compile project and execute all possible checks. Script will not let you make commits before all issues generated by compiler and static analysis tools will be fixed and all tests will pass.
- `remote-iex.sh` provides direct access to remote erlang node through `iex`.
- `cluster-iex.sh` connects current erlang node to remote erlang node. All local debug tools (for example Observer) are available to debug remote node. Hot code reloading is also available.
- `docs.sh` creates and opens project documentation.
- `coverage.sh` creates and opens project test coverage report.

Some system variables are required by some scripts, description of all variables

- `ERLANG_HOST` remote hostname to connect, example: *`www.elixir-app.com`*
- `ERLANG_OTP_APPLICATION` lowercase and snakecase standard OTP application name, example: *`elixir_app`*
- `ERLANG_COOKIE` remote Erlang node cookie, example: *`OEBy/p9vFWi85XTeYOUvIwLr/sZctkHPKWNxfTtf81M=`*
- `ENABLE_DIALYZER` run Dialyzer checks in pre-commit hooks or not, example: *`false`*
- `CONFLUENCE_SUBDOMAIN` first part of confluence domain name, example: *`mycompany`.atlassian.net/wiki/spaces/PROJECT/pages/323322444/elixir-app*
- `CONFLUENCE_PAGE_ID` numeric id of project page, example: *mycompany.atlassian.net/wiki/spaces/PROJECT/pages/`323322444`/elixir-app*
- `CONFLUENCE_SECRET` access token generated from atlassian login and password in the following way *`"#{login}:#{password}" |> Base.encode64`*, example: *`bG9naW46cGFzc3dvcmQ=`*

Variables can be defined in `scripts/.env` file locally (useful for development) or globally in the system.

## TODO

- `scripts/release.sh` script bumps version, creates new release, changelog and pushes to github.
