defmodule Mix.Tasks.Boilex.Init do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Creates new configuration files for Elixir project dev tools"

  @moduledoc """
  Creates new (or updates old) configuration files for Elixir dev tools and scripts.

  # Usage
  ```
  cd ./myproject
  mix boilex.init
  ```
  """

  @spec run(OptionParser.argv) :: :ok
  def run(_) do

    otp_application  = fetch_otp_application_name()
    include_postgres = Mix.shell.yes?("Include postgres stuff to CircleCI config?")
    erlang_cookie    = :crypto.strong_rand_bytes(32) |> Base.encode64
    assigns          = [
                        otp_application:  otp_application,
                        erlang_cookie:    erlang_cookie,
                        include_postgres: include_postgres,
                       ]

    # priv dir for usage in Elixir code
    create_directory  "priv"
    # dev tools configs
    create_file       "VERSION",                version_text()
    create_file       "CHANGELOG.md",           changelog_text()
    create_file       "coveralls.json",         coveralls_simple_template(assigns)
    create_file       ".credo.exs",             credo_text()
    create_file       ".dialyzer_ignore",       dialyzer_ignore_text()
    create_file       ".editorconfig",          editorconfig_text()
    create_file       ".formatter.exs",         formatter_text()
    # docker stuff
    create_file       "Dockerfile",             dockerfile_template(assigns)
    create_file       "docker-compose.yml",     docker_compose_template(assigns)
    # local dev scripts
    create_directory  "scripts"
    create_file       "scripts/.env",           env_template(assigns)
    create_script     "scripts/pre-commit.sh",  pre_commit_text()
    create_script     "scripts/remote-iex.sh",  remote_iex_text()
    create_script     "scripts/cluster-iex.sh", cluster_iex_text()
    create_script     "scripts/check-vars.sh",  check_vars_text()
    create_script     "scripts/show-vars.sh",   show_vars_text()
    create_script     "scripts/docs.sh",        docs_text()
    create_script     "scripts/coverage.sh",    coverage_text()
    create_script     "scripts/start.sh",       start_text()
    create_script     "scripts/docker-iex.sh",  docker_iex_template(assigns)
    # circleci
    create_directory  ".circleci"
    create_file       ".circleci/config.yml",   circleci_config_template(assigns)
    # instructions
    :ok = todo_instructions(assigns) |> Mix.shell.info
  end

  #
  # dev tools configs
  #

  embed_text :version, """
  0.1.0
  """

  embed_text :changelog, ""

  embed_template :coveralls_simple, """
  {
    "coverage_options": {
      "treat_no_relevant_lines_as_covered": false,
      "minimum_coverage": 100
    },
    "skip_files": [
      "test/*",

      "lib/<%= @otp_application %>_web.ex",
      "lib/<%= @otp_application %>/application.ex",
      "lib/<%= @otp_application %>/repo.ex",

      "lib/<%= @otp_application %>_web/endpoint.ex",
      "lib/<%= @otp_application %>_web/router.ex"
    ]
  }
  """

  embed_text :credo, """
  %{
    #
    # You can have as many configs as you like in the `configs:` field.
    configs: [
      %{
        #
        # Run any exec using `mix credo -C <name>`. If no exec name is given
        # "default" is used.
        #
        name: "default",
        #
        # These are the files included in the analysis:
        files: %{
          #
          # You can give explicit globs or simply directories.
          # In the latter case `**/*.{ex,exs}` will be used.
        #
          included: ["lib/", "src/", "web/", "apps/"],
          excluded: [~r"/_build/", ~r"/deps/"]
        },
        #
        # If you create your own checks, you must specify the source files for
        # them here, so they can be loaded by Credo before running the analysis.
        #
        requires: [],
        #
        # Credo automatically checks for updates, like e.g. Hex does.
        # You can disable this behaviour below:
        #
        check_for_updates: true,
        #
        # If you want to enforce a style guide and need a more traditional linting
        # experience, you can change `strict` to `true` below:
        #
        strict: true,
        #
        # If you want to use uncolored output by default, you can change `color`
        # to `false` below:
        #
        color: true,
        #
        # You can customize the parameters of any check by adding a second element
        # to the tuple.
        #
        # To disable a check put `false` as second element:
        #
        #     {Credo.Check.Design.DuplicatedCode, false}
        #
        checks: [
          {Credo.Check.Consistency.ExceptionNames},
          {Credo.Check.Consistency.LineEndings},
          {Credo.Check.Consistency.ParameterPatternMatching},
          {Credo.Check.Consistency.SpaceAroundOperators},
          {Credo.Check.Consistency.SpaceInParentheses},
          {Credo.Check.Consistency.TabsOrSpaces},

          # For some checks, like AliasUsage, you can only customize the priority
          # Priority values are: `low, normal, high, higher`
          #
          {Credo.Check.Design.AliasUsage, false},

          # For others you can set parameters

          # If you don't want the `setup` and `test` macro calls in ExUnit tests
          # or the `schema` macro in Ecto schemas to trigger DuplicatedCode, just
          # set the `excluded_macros` parameter to `[:schema, :setup, :test]`.
          #
          {Credo.Check.Design.DuplicatedCode, excluded_macros: []},

          # You can also customize the exit_status of each check.
          # If you don't want TODO comments to cause `mix credo` to fail, just
          # set this value to 0 (zero).
          #
          {Credo.Check.Design.TagTODO, priority: :low, exit_status: 0},
          {Credo.Check.Design.TagFIXME, priority: :low, exit_status: 0},

          {Credo.Check.Readability.FunctionNames},
          {Credo.Check.Readability.LargeNumbers},
          {Credo.Check.Readability.MaxLineLength, false},
          {Credo.Check.Readability.ModuleAttributeNames},
          {Credo.Check.Readability.ModuleDoc, false},
          {Credo.Check.Readability.ModuleNames, priority: :high},
          {Credo.Check.Readability.ParenthesesOnZeroArityDefs, priority: :high},
          {Credo.Check.Readability.ParenthesesInCondition, priority: :high},
          {Credo.Check.Readability.PredicateFunctionNames, priority: :high},
          {Credo.Check.Readability.PreferImplicitTry, false},
          {Credo.Check.Readability.RedundantBlankLines, priority: :low},
          {Credo.Check.Readability.StringSigils},
          {Credo.Check.Readability.TrailingBlankLine},
          {Credo.Check.Readability.TrailingWhiteSpace},
          {Credo.Check.Readability.VariableNames},
          {Credo.Check.Readability.Semicolons},
          {Credo.Check.Readability.SpaceAfterCommas, priority: :low},

          {Credo.Check.Refactor.DoubleBooleanNegation, priority: :high},
          {Credo.Check.Refactor.CondStatements},
          {Credo.Check.Refactor.CyclomaticComplexity, priority: :high, exit_status: 2, max_complexity: 12},
          {Credo.Check.Refactor.FunctionArity},
          {Credo.Check.Refactor.LongQuoteBlocks},
          {Credo.Check.Refactor.MatchInCondition},
          {Credo.Check.Refactor.NegatedConditionsInUnless, priority: :high, exit_status: 2},
          {Credo.Check.Refactor.NegatedConditionsWithElse, priority: :normal},
          {Credo.Check.Refactor.Nesting, max_nesting: 3, priority: :high, exit_status: 2},
          {Credo.Check.Refactor.PipeChainStart, false},
          {Credo.Check.Refactor.UnlessWithElse, priority: :higher, exit_status: 2},

          {Credo.Check.Warning.BoolOperationOnSameValues, priority: :high, exit_status: 2},
          {Credo.Check.Warning.IExPry, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.IoInspect, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.LazyLogging, false},
          {Credo.Check.Warning.OperationOnSameValues, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.OperationWithConstantResult, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedEnumOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedFileOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedKeywordOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedListOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedPathOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedRegexOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedStringOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.UnusedTupleOperation, priority: :higher, exit_status: 2},
          {Credo.Check.Warning.RaiseInsideRescue, priority: :higher, exit_status: 2},

          # Controversial and experimental checks (opt-in, just remove `, false`)
          #
          {Credo.Check.Refactor.ABCSize, false},
          {Credo.Check.Refactor.AppendSingleItem, priority: :normal},
          {Credo.Check.Refactor.VariableRebinding, priority: :normal},
          {Credo.Check.Warning.MapGetUnsafePass, priority: :high, exit_status: 0},
          {Credo.Check.Consistency.MultiAliasImportRequireUse, false},

          # Deprecated checks (these will be deleted after a grace period)
          #
          {Credo.Check.Readability.Specs, false},
          {Credo.Check.Warning.NameRedeclarationByAssignment, false},
          {Credo.Check.Warning.NameRedeclarationByCase, priority: :normal},
          {Credo.Check.Warning.NameRedeclarationByDef, priority: :normal},
          {Credo.Check.Warning.NameRedeclarationByFn, priority: :normal},

          # Custom checks can be created using `mix credo.gen.check`.
          #
        ]
      }
    ]
  }
  """

  embed_text :dialyzer_ignore, """
  Any dialyzer's error output lines putted to this text file will be completely ignored by dialyzer's type checks.
  Please not abuse this file, type checks are VERY important.
  Use this file just in case of bad 3rd party auto-generated code.
  """

  embed_text :editorconfig, """
  # Editor configuration file
  # For Emacs install package `editorconfig`
  # For Atom install package `editorconfig`
  # For Sublime Text install package `EditorConfig`
  root = true

  [*]
  indent_style = space
  indent_size = 2
  end_of_line = lf
  charset = utf-8
  trim_trailing_whitespace = true
  insert_final_newline = true
  max_line_length = 100

  [*.md]
  indent_style = space
  indent_size = 2

  [*.yml]
  indent_style = space
  indent_size = 2

  [*.json]
  indent_style = space
  indent_size = 2
  """

  embed_text :formatter, """
  [
    inputs: [".credo.exs", ".formatter.exs", "mix.exs", "{config,lib,priv,rel,test}/**/*.{ex,exs}"],
    line_length: 140,
    locals_without_parens: [
      # Ecto

      ## schema
      field: :*,
      belongs_to: :*,
      has_one: :*,
      has_many: :*,
      many_to_many: :*,
      embeds_one: :*,
      embeds_many: :*,

      ## migration
      create: :*,
      create_if_not_exists: :*,
      alter: :*,
      drop: :*,
      drop_if_exists: :*,
      rename: :*,
      add: :*,
      remove: :*,
      modify: :*,
      execute: :*
    ]
  ]
  """

  #
  # docker stuff
  #

  embed_template :dockerfile, """
  FROM elixir:<%= elixir_version() %>

  WORKDIR /app

  COPY . .

  RUN cd / && \\
      mix do local.hex --force, local.rebar --force && \\
      mix archive.install github heathmont/ex_env tag v0.2.2 --force && \\
      cd /app # && \\
      # rm -rf ./_build/ && \\
      # echo "Compressing static files..." && \\
      # mix phx.digest && \\
      # MIX_ENV=prelive mix compile.protocols && \\
      # MIX_ENV=prod    mix compile.protocols && \\
      # MIX_ENV=qa      mix compile.protocols && \\
      # MIX_ENV=staging mix compile.protocols

  CMD echo "Checking system variables..." && \\
      scripts/show-vars.sh \\
        "MIX_ENV" \\
        "ERLANG_OTP_APPLICATION" \\
        "ERLANG_HOST" \\
        "ERLANG_MIN_PORT" \\
        "ERLANG_MAX_PORT" \\
        "ERLANG_MAX_PROCESSES" \\
        "ERLANG_COOKIE" && \\
      scripts/check-vars.sh "in system" \\
        "MIX_ENV" \\
        "ERLANG_OTP_APPLICATION" \\
        "ERLANG_HOST" \\
        "ERLANG_MIN_PORT" \\
        "ERLANG_MAX_PORT" \\
        "ERLANG_MAX_PROCESSES" \\
        "ERLANG_COOKIE" && \\
      # echo "Running ecto create..." && \\
      # mix ecto.create && \\
      # echo "Running ecto migrate..." && \\
      # mix ecto.migrate && \\
      # echo "Running ecto seeds..." && \\
      # mix run priv/repo/seeds.exs && \\
      echo "Running app..." && \\
      elixir \\
        --name "$ERLANG_OTP_APPLICATION@$ERLANG_HOST" \\
        --cookie "$ERLANG_COOKIE" \\
        --erl "+K true +A 32 +P $ERLANG_MAX_PROCESSES" \\
        --erl "-kernel inet_dist_listen_min $ERLANG_MIN_PORT" \\
        --erl "-kernel inet_dist_listen_max $ERLANG_MAX_PORT" \\
        -pa "_build/$MIX_ENV/lib/<%= @otp_application %>/consolidated/" \\
        -S mix run \\
        --no-halt
  """

  embed_template :docker_compose, """
  version: "3"

  services:
    main:
      image: "<%= @otp_application |> String.replace("_", "-") %>:master"
      ports:
        # - "4369:4369"         # EPMD
        - "9100-9105:9100-9105" # Distributed Erlang
      environment:
        MIX_ENV: staging
        ERLANG_OTP_APPLICATION: "<%= @otp_application %>"
        ERLANG_HOST: "127.0.0.1"
        ERLANG_MIN_PORT: 9100
        ERLANG_MAX_PORT: 9105
        ERLANG_MAX_PROCESSES: 1000000
        ERLANG_COOKIE: "<%= @erlang_cookie %>"
      networks:
        - default
      deploy:
        resources:
          limits:
            memory: 4096M
          reservations:
            memory: 2048M
        restart_policy:
          condition: on-failure
          delay: 5s
  """

  #
  # local dev scripts
  #

  embed_template :env, """
  ERLANG_HOST=127.0.0.1
  ERLANG_OTP_APPLICATION="<%= @otp_application %>"
  ERLANG_COOKIE="<%= @erlang_cookie %>"
  ENABLE_DIALYZER=false
  CONFLUENCE_SUBDOMAIN=
  CONFLUENCE_PAGE_ID=
  """

  embed_text :pre_commit, """
  #!/bin/bash

  set -e
  export MIX_ENV=test

  if [[ -L "$0" ]] && [[ -e "$0" ]] ; then
    script_file="$(readlink "$0")"
  else
    script_file="$0"
  fi

  scripts_dir="$(dirname -- "$script_file")"
  export $(cat "$scripts_dir/.env" | xargs)
  "$scripts_dir/check-vars.sh" "in scripts/.env file" "ENABLE_DIALYZER"

  mix deps.get
  mix deps.compile
  mix compile --warnings-as-errors
  mix credo --strict
  mix coveralls.html
  mix docs

  if [ "$ENABLE_DIALYZER" = true ] ; then
    mix dialyzer --halt-exit-status
  fi

  echo "Congratulations! Pre-commit hook checks passed!"
  """

  embed_text :remote_iex, """
  #!/bin/bash

  set -e

  script_file="$0"
  scripts_dir="$(dirname -- "$script_file")"
  export $(cat "$scripts_dir/.env" | xargs)
  "$scripts_dir/check-vars.sh" "in scripts/.env file" "ERLANG_HOST" "ERLANG_OTP_APPLICATION" "ERLANG_COOKIE"

  iex \\
    --remsh "$ERLANG_OTP_APPLICATION@$ERLANG_HOST" \\
    --name "remote-$(date +%s)@$ERLANG_HOST" \\
    --cookie "$ERLANG_COOKIE" \\
    --erl "+K true +A 32" \\
    --erl "-kernel inet_dist_listen_min 9100" \\
    --erl "-kernel inet_dist_listen_max 9199"
  """

  embed_text :cluster_iex, """
  #!/bin/bash

  set -e

  script_file="$0"
  scripts_dir="$(dirname -- "$script_file")"
  export $(cat "$scripts_dir/.env" | xargs)
  "$scripts_dir/check-vars.sh" "in scripts/.env file" "ERLANG_HOST" "ERLANG_OTP_APPLICATION" "ERLANG_COOKIE"

  iex \\
    --name "local-$(date +%s)@$ERLANG_HOST" \\
    --cookie "$ERLANG_COOKIE" \\
    --erl "+K true +A 32" \\
    --erl "-kernel inet_dist_listen_min 9100" \\
    --erl "-kernel inet_dist_listen_max 9199" \\
    -e ":timer.sleep(5000); Node.connect(:\\"$ERLANG_OTP_APPLICATION@$ERLANG_HOST\\")" \\
    -S mix

  # To push local App.Module module bytecode to remote erlang node run
  #
  # nl(App.Module)
  #
  """

  embed_text :check_vars, """
  #!/bin/bash

  set -e

  arguments=( "$@" )
  variables=( "${arguments[@]:1}" )
  message="${arguments[0]}"

  for varname in "${variables[@]}"
  do
    if [[ -z "${!varname}" ]]; then
        echo "\\nplease set variable $varname $message\\n"
        exit 1
    fi
  done
  """

  embed_text :show_vars, """
  #!/bin/bash

  set -e

  variables=( "$@" )

  echo ""
  for varname in "${variables[@]}"
  do
    echo "$varname=${!varname}"
  done
  echo ""
  """

  embed_text :docs, """
  #!/bin/bash

  set -e

  mix compile
  mix docs
  echo "Documentation has been generated!"
  open ./doc/index.html
  """

  embed_text :coverage, """
  #!/bin/bash

  mix compile
  mix coveralls.html
  echo "Coverage report has been generated!"
  open ./cover/excoveralls.html
  """

  embed_text :start, """
  #!/bin/bash

  set -e

  iex \\
    --erl "+K true +A 32" \\
    --erl "-kernel inet_dist_listen_min 9100" \\
    --erl "-kernel inet_dist_listen_max 9199" \\
    --erl "-kernel shell_history enabled" \\
    -S mix
  """

  embed_template :docker_iex, """
  #!/bin/bash

  set -e

  docker exec -it $(docker ps | grep "<%= @otp_application %>_main" | awk '{print $1;}') /app/scripts/remote-iex.sh
  """

  #
  # circleci
  #

  embed_template :circleci_config, """
  defaults: &defaults
    working_directory: /app
    docker:
      - image: heathmont/elixir-builder:<%= elixir_version() %><%= if @include_postgres, do: "\n"<>postgres_circleci_image() %>

  check_vars: &check_vars
    run:
      name:       Check variables
      command:    ./scripts/check-vars.sh "in system" "ROBOT_SSH_KEY" "DOCKER_EMAIL" "DOCKER_ORG" "DOCKER_PASS" "DOCKER_USER"

  setup_ssh_key: &setup_ssh_key
    run:
      name:       Setup robot SSH key
      command:    echo "$ROBOT_SSH_KEY" | base64 --decode > $HOME/.ssh/id_rsa.robot && chmod 600 $HOME/.ssh/id_rsa.robot && ssh-add $HOME/.ssh/id_rsa.robot

  setup_ssh_config: &setup_ssh_config
    run:
      name:        Setup SSH config
      command:     echo -e "Host *\\n IdentityFile $HOME/.ssh/id_rsa.robot\\n IdentitiesOnly yes" > $HOME/.ssh/config

  fetch_submodules: &fetch_submodules
    run:
      name:       Fetch submodules
      command:    git submodule update --init --recursive

  hex_auth: &hex_auth
    run:
      name:       Hex auth
      command:    mix hex.organization auth $HEX_ORGANIZATION --key $HEX_API_KEY

  fetch_dependencies: &fetch_dependencies
    run:
      name:       Fetch dependencies
      command:    mix deps.get

  compile_dependencies: &compile_dependencies
    run:
      name:       Compile dependencies
      command:    mix deps.compile

  compile_protocols: &compile_protocols
    run:
      name:       Compile protocols
      command:    mix compile.protocols --warnings-as-errors

  version: 2
  jobs:
    test:
      <<: *defaults
      working_directory: /app
      environment:
        MIX_ENV: test
      steps:
        - checkout
        - run:
            name:       Check variables
            command:    ./scripts/check-vars.sh "in system" "ROBOT_SSH_KEY" "COVERALLS_REPO_TOKEN"
        - <<: *setup_ssh_key
        - <<: *setup_ssh_config
        - <<: *fetch_submodules
        - restore_cache:
            keys:
              - v1-test-{{ checksum "mix.lock" }}-{{ .Revision }}
              - v1-test-{{ checksum "mix.lock" }}-
              - v1-test-
        # - <<: *hex_auth
        - <<: *fetch_dependencies
        - <<: *compile_dependencies
        - <<: *compile_protocols
        # - run:
        #     name:       Create test DB
        #     command:    mix ecto.create
        # - run:
        #     name:       Migrate test DB
        #     command:    mix ecto.migrate
        - run:
            name:       Run tests
            command:    mix coveralls.circle
        - run:
            name:       Run style checks
            command:    mix credo --strict
        - run:
            name:       Run Dialyzer type checks
            command:    mix dialyzer --halt-exit-status
            no_output_timeout: 15m
        - save_cache:
            key: v1-test-{{ checksum "mix.lock" }}-{{ .Revision }}
            paths:
              - _build
              - deps
              - ~/.mix

    build_qa:
      <<: *defaults
      environment:
        MIX_ENV: qa
      steps:
        - checkout
        - setup_remote_docker
        - <<: *check_vars
        - <<: *setup_ssh_key
        - <<: *setup_ssh_config
        - <<: *fetch_submodules
        - restore_cache:
            keys:
              - v1-qa-{{ checksum "mix.lock" }}-{{ .Revision }}
              - v1-qa-{{ checksum "mix.lock" }}-
              - v1-qa-
        # - <<: *hex_auth
        - <<: *fetch_dependencies
        - <<: *compile_dependencies
        - <<: *compile_protocols
        - save_cache:
            key: v1-qa-{{ checksum "mix.lock" }}-{{ .Revision }}
            paths:
              - _build
              - deps
              - ~/.mix
        - persist_to_workspace:
            root: ./
            paths:
              - _build/qa
              - deps

    build_prelive:
      <<: *defaults
      environment:
        MIX_ENV: prelive
      steps:
        - checkout
        - setup_remote_docker
        - <<: *check_vars
        - <<: *setup_ssh_key
        - <<: *setup_ssh_config
        - <<: *fetch_submodules
        - restore_cache:
            keys:
              - v1-prelive-{{ checksum "mix.lock" }}-{{ .Revision }}
              - v1-prelive-{{ checksum "mix.lock" }}-
              - v1-prelive-
        # - <<: *hex_auth
        - <<: *fetch_dependencies
        - <<: *compile_dependencies
        - <<: *compile_protocols
        - save_cache:
            key: v1-prelive-{{ checksum "mix.lock" }}-{{ .Revision }}
            paths:
              - _build
              - deps
              - ~/.mix
        - persist_to_workspace:
            root: ./
            paths:
              - _build/prelive

    build_staging:
      <<: *defaults
      environment:
        MIX_ENV: staging
      steps:
        - checkout
        - setup_remote_docker
        - <<: *check_vars
        - <<: *setup_ssh_key
        - <<: *setup_ssh_config
        - <<: *fetch_submodules
        - restore_cache:
            keys:
              - v1-staging-{{ checksum "mix.lock" }}-{{ .Revision }}
              - v1-staging-{{ checksum "mix.lock" }}-
              - v1-staging-
        # - <<: *hex_auth
        - <<: *fetch_dependencies
        - <<: *compile_dependencies
        - <<: *compile_protocols
        - save_cache:
            key: v1-staging-{{ checksum "mix.lock" }}-{{ .Revision }}
            paths:
              - _build
              - deps
              - ~/.mix
        - persist_to_workspace:
            root: ./
            paths:
              - _build/staging

    build_prod:
      <<: *defaults
      environment:
        MIX_ENV: prod
      steps:
        - checkout
        - setup_remote_docker
        - <<: *check_vars
        - <<: *setup_ssh_key
        - <<: *setup_ssh_config
        - <<: *fetch_submodules
        - restore_cache:
            keys:
              - v1-prod-{{ checksum "mix.lock" }}-{{ .Revision }}
              - v1-prod-{{ checksum "mix.lock" }}-
              - v1-prod-
        # - <<: *hex_auth
        - <<: *fetch_dependencies
        - <<: *compile_dependencies
        - <<: *compile_protocols
        - save_cache:
            key: v1-prod-{{ checksum "mix.lock" }}-{{ .Revision }}
            paths:
              - _build
              - deps
              - ~/.mix
        - persist_to_workspace:
            root: ./
            paths:
              - _build/prod

    docker_build:
      <<: *defaults
      environment:
        MIX_ENV: prod
      steps:
        - checkout
        - setup_remote_docker
        - attach_workspace:
            at: ./
        - run:
            name:       Login to docker
            command:    docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS
        - run:
            name:       Building docker image
            command:    export $(cat "./scripts/.env" | xargs) && mix boilex.ci.docker.build "$CIRCLE_TAG"
        - run:
            name:       Push image to docker hub
            command:    export $(cat "./scripts/.env" | xargs) && mix boilex.ci.docker.push "$CIRCLE_TAG"

    doc:
      <<: *defaults
      environment:
        MIX_ENV: dev
      working_directory: /app
      steps:
        - checkout
        - run:
            name:       Check variables
            command:    ./scripts/check-vars.sh "in system" "ROBOT_SSH_KEY" "CONFLUENCE_SECRET"
        - <<: *setup_ssh_key
        - <<: *setup_ssh_config
        - <<: *fetch_submodules
        - restore_cache:
            keys:
              - v1-doc-{{ checksum "mix.lock" }}-{{ .Revision }}
              - v1-doc-{{ checksum "mix.lock" }}-
              - v1-doc-
        # - <<: *hex_auth
        - <<: *fetch_dependencies
        - <<: *compile_dependencies
        - <<: *compile_protocols
        - save_cache:
            key: v1-doc-{{ checksum "mix.lock" }}-{{ .Revision }}
            paths:
              - _build
              - deps
              - ~/.mix
        - run:
            name:       Compile documentation
            command:    mix docs<%= if @include_postgres, do: "\n"<>postgres_circleci_erd() %>
        - run:
            name:       Push documentation to confluence
            command:    export $(cat "./scripts/.env" | xargs) && mix boilex.ci.confluence.push "$CIRCLE_TAG"

  workflows:
    version: 2
    test:
      jobs:
        - test:
            context: global
            filters:
              branches:
                only: /^([A-Z]{2,}-[0-9]+|hotfix-.+|feature-.*)$/
    test-build:
      jobs:
        - test:
            context: global
            filters:
              branches:
                only: /^(build-.+)$/
        - build_qa:
            context: global
            filters:
              branches:
                only: /^(build-.+)$/

        - build_prelive:
            context: global
            filters:
              branches:
                only: /^(build-.+)$/

        - build_staging:
            context: global
            filters:
              branches:
                only: /^(build-.+)$/

        - build_prod:
            context: global
            filters:
              branches:
                only: /^(build-.+)$/

        - docker_build:
            context: global
            filters:
              branches:
                only: /^(build-.+)$/
            requires:
              - test
              - build_qa
              - build_prelive
              - build_staging
              - build_prod
    test-build-doc:
      jobs:
        - test:
            context: global
            filters:
              tags:
                only: /.*/
              branches:
                only: /^master$/

        - build_qa:
            context: global
            filters:
              tags:
                only: /.*/
              branches:
                only: /^master$/

        - build_prelive:
            context: global
            filters:
              tags:
                only: /.*/
              branches:
                only: /^master$/

        - build_staging:
            context: global
            filters:
              tags:
                only: /.*/
              branches:
                only: /^master$/

        - build_prod:
            context: global
            filters:
              tags:
                only: /.*/
              branches:
                only: /^master$/

        - docker_build:
            context: global
            filters:
              tags:
                only: /.*/
              branches:
                only: /^master$/
            requires:
              - test
              - build_qa
              - build_prelive
              - build_staging
              - build_prod
        - doc:
            context: global
            filters:
              tags:
                only: /.*/
              branches:
                only: /^master$/
  """

  #
  # priv
  #

  defp fetch_otp_application_name do
    Mix.shell.prompt("Please type OTP application name>")
    |> String.trim
    |> Macro.underscore
    |> String.downcase
    |> case do
      "" ->
        Mix.shell.error("Empty OTP application name!")
        fetch_otp_application_name()
      name ->
        case Regex.match?(~r/^([a-z]+[a-z0-9]*)(_[a-z]+[a-z0-9]*)*([a-z]+[a-z0-9]*)$/, name)  do
          true -> name
          false ->
            Mix.shell.error("Invalid OTP application name!")
            fetch_otp_application_name()
        end
    end
  end

  defp todo_instructions(assigns) do
    """
    #{IO.ANSI.magenta}
    *****************
    !!! IMPORTANT !!!
    *****************

    #{IO.ANSI.cyan}
    REPLACE `version` LINE OF `project` FUNCTION IN `mix.exs` FILE WITH
    #{IO.ANSI.green}


      version: ("VERSION" |> File.read! |> String.trim),


    #{IO.ANSI.cyan}
    ADD THE FOLLOWING PARAMETERS TO `project` FUNCTION IN `mix.exs` FILE
    #{IO.ANSI.green}


      # excoveralls
      test_coverage:      [tool: ExCoveralls],
      preferred_cli_env:  [
        "coveralls":            :test,
        "coveralls.travis":     :test,
        "coveralls.circle":     :test,
        "coveralls.semaphore":  :test,
        "coveralls.post":       :test,
        "coveralls.detail":     :test,
        "coveralls.html":       :test,
      ],
      # dialyxir
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore",
        plt_add_apps: [
          :mix,
          :ex_unit,
        ]
      ],
      # ex_doc
      name:         "#{ assigns |> Keyword.get(:otp_application) |> Macro.camelize }",
      source_url:   "TODO_PUT_HERE_GITHUB_URL",
      homepage_url: "TODO_PUT_HERE_GITHUB_URL",
      docs:         [main: "readme", extras: ["README.md"]],
      # hex.pm stuff
      description:  "TODO_ADD_DESCRIPTION",
      package: [
        licenses: ["Apache 2.0"],
        files: ["lib", "priv", "mix.exs", "README*", "VERSION*"],
        maintainers: ["TODO_ADD_MAINTAINER"],
        links: %{
          "GitHub" => "TODO_PUT_HERE_GITHUB_URL",
          "Author's home page" => "TODO_PUT_HERE_HOMEPAGE_URL",
        }
      ],


    #{IO.ANSI.cyan}
    If your project is OTP application (not just library),
    probably you would like to add `stop` function to your
    `application.ex` file to prevent situations when
    erlang node continue to run while your
    application has been stopped (because of some reason). Example:
    #{IO.ANSI.green}


      def stop(reason) do
        "\#{__MODULE__} application is stopped, trying to shutdown erlang node ..."
        |> Logger.error([reason: reason])
        :init.stop()
      end


    #{IO.ANSI.cyan}
    Please configure `scripts/.env` file if you want to use distributed erlang features in development process.

    #{IO.ANSI.magenta}
    *****************
    !!! IMPORTANT !!!
    *****************
    #{IO.ANSI.reset}
    """
  end

  defp create_script(name, value) do
    create_file       name, value
    :ok = File.chmod  name, 0o755
  end

  defp postgres_circleci_image do
    """
          environment:
            POSTGRES_URL: ecto://postgres:postgres@localhost/platform88
        - image: circleci/postgres:9.6.5-alpine-ram
    """
    |> String.trim("\n")
  end

  defp postgres_circleci_erd do
    """
          - run:
              name:       Setup test DB
              command:    mix ecto.setup
          - run:
              name:       Generate database ERD
              command:    export PROJECT_DIRECTORY="$(pwd)" && pushd /schemacrawler-14.19.01-distribution/_schemacrawler/ && ./schemacrawler.sh -server=postgresql -host=127.0.0.1 -user=postgres -password=postgres -database=platform88 -infolevel=standard -routines= -command=schema -outputformat=png -o "$PROJECT_DIRECTORY/doc/database-ERD.png" && popd
    """
    |> String.trim("\n")
  end

  defp elixir_version do
    [{:elixir, _, version}] =
      :application.which_applications
      |> Enum.filter(fn({app, _, _}) ->
        app == :elixir
      end)

    version
    |> :erlang.list_to_binary
  end

end
