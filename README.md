# Beginner Chef Project: Automated Web Server

This project teaches Chef from the beginning by solving one simple problem:

> Take a clean Ubuntu server and automatically configure it as a web server.

After Chef runs, the server will have nginx installed, a dedicated application user, a website directory, a generated home page, an nginx configuration, and a running web service on port `8080`.

## What Chef is doing

Without Chef, an administrator would log in to a server and run commands manually. Chef stores those configuration steps as code so the same result can be created repeatedly and consistently.

```text
Chef recipe
    |
    |-- installs nginx
    |-- creates an application group and user
    |-- creates /var/www/chef-demo
    |-- generates the website and nginx configuration
    |-- enables and starts nginx
    `-- reloads nginx only when its configuration changes
```

Chef is **idempotent**: after the server reaches the required state, running Chef again should make no unnecessary changes.

## Project structure

```text
chef-project/
├── .github/workflows/chef-validation.yml
├── .gitignore
├── .kitchen.yml
├── Policyfile.rb
├── README.md
└── cookbooks/
    └── web_server/
        ├── metadata.rb
        ├── attributes/
        │   └── default.rb
        ├── recipes/
        │   └── default.rb
        ├── templates/
        │   └── default/
        │       ├── index.html.erb
        │       └── nginx-site.conf.erb
        └── test/integration/default/
            └── default_test.rb
```

## Explanation of every file

### `README.md`

This is the project guide. It explains the purpose, structure, commands, and Chef concepts so a new developer can understand the project before running it.

### `Policyfile.rb`

A Policyfile tells Chef which cookbook and recipe belong to this project.

```ruby
name 'web_server_policy'
```

This gives the policy a readable name.

```ruby
default_source :supermarket
```

This tells Chef where community cookbooks would come from. This project does not currently download any community cookbook, but the source is declared explicitly.

```ruby
run_list 'web_server::default'
```

The run list tells Chef which recipe to execute. Here it runs the `default.rb` recipe from the `web_server` cookbook.

```ruby
cookbook 'web_server', path: 'cookbooks/web_server'
```

This tells Chef that our cookbook is stored locally in `cookbooks/web_server`.

### `.kitchen.yml`

Test Kitchen creates a temporary Ubuntu container, runs the cookbook, and executes the InSpec tests. This lets us test safely without changing a personal computer or production server.

- `driver: dokken` uses Docker containers for testing.
- `provisioner: dokken` runs Chef inside the test container.
- `verifier: inspec` runs validation tests after Chef finishes.
- `ubuntu-22.04` is the test operating system.
- `recipe[web_server::default]` is the recipe being tested.

### `.gitignore`

Chef and Test Kitchen create temporary files. `.gitignore` prevents those generated files from being committed to GitHub.

### `.github/workflows/chef-validation.yml`

GitHub Actions automatically checks the cookbook whenever project code is pushed or included in a pull request.

It performs two safe checks:

1. **Cookstyle** checks Ruby and Chef code style.
2. **Policyfile validation** confirms that Chef can resolve the cookbook and run list.

This workflow does not configure an AWS server.

### `cookbooks/web_server/metadata.rb`

Every cookbook needs metadata. It identifies the cookbook, owner, license, purpose, version, required Chef version, and supported operating system.

### `cookbooks/web_server/attributes/default.rb`

Attributes hold values that may change between environments. The recipe reads these values rather than repeating hard-coded values throughout the code.

For example:

```ruby
default['web_server']['port'] = 8080
```

If the application later needs port `8081`, we can change one attribute instead of editing multiple resources and templates.

### `cookbooks/web_server/recipes/default.rb`

This is the main automation code. Chef reads it from top to bottom and creates a collection of resources describing the required server state.

The recipe uses these Chef resources:

| Resource | Why it is used |
|---|---|
| `apt_update` | Refresh Ubuntu package information |
| `package` | Install nginx |
| `group` | Create a dedicated application group |
| `user` | Create a dedicated service account |
| `directory` | Create the website directory with controlled ownership |
| `service` | Enable nginx at boot and ensure it is running |
| `template` | Generate files using attributes and ERB templates |
| `file` | Remove Ubuntu's default nginx site |
| `link` | Enable our nginx site using a symbolic link |

The `notifies` statements tell Chef to validate and reload nginx only when configuration files change.

### `templates/default/index.html.erb`

This is an ERB template for the website home page. Chef replaces expressions such as `<%= @app_name %>` with values supplied by the recipe.

### `templates/default/nginx-site.conf.erb`

This template generates the nginx site configuration. It uses the configured port and website directory, and it provides a `/health` endpoint for automated health checks.

### `test/integration/default/default_test.rb`

These are InSpec tests. They verify the final server state rather than simply assuming the Chef run worked.

The tests check that:

- nginx is installed;
- the application user and group exist;
- the website directory has the correct owner and permissions;
- the generated website contains the expected text;
- nginx is enabled and running;
- port `8080` is listening; and
- the `/health` endpoint returns HTTP status `200`.

## How to run the project

### Option 1: Test Kitchen with Docker

Install Chef Workstation and Docker Desktop. From the repository root, run:

```bash
chef install Policyfile.rb
chef exec cookstyle cookbooks
chef gem install kitchen-dokken --no-document
kitchen test
```

`kitchen test` performs the full lifecycle:

1. Creates a temporary Ubuntu container.
2. Runs the Chef cookbook.
3. Executes the InSpec tests.
4. Deletes the temporary container.

### Option 2: Chef local mode on an Ubuntu test server

Clone the repository on an authorized Ubuntu test server with Chef Workstation or Chef Infra Client installed. From the repository root, run:

```bash
sudo chef-client --local-mode \
  --cookbook-path ./cookbooks \
  --runlist 'recipe[web_server::default]'
```

Then verify the result:

```bash
curl http://localhost:8080
curl http://localhost:8080/health
```

Run the same `chef-client` command again. The second run should report no unnecessary updates. That demonstrates idempotency.

## What to observe during a Chef run

Chef reports each resource as either:

- **up to date**: the server already matches the recipe;
- **updated**: Chef changed the server; or
- **failed**: Chef could not complete the resource.

The first run should update several resources. The second run should show that most or all resources are already up to date.

## Skills demonstrated

- Chef cookbook structure
- Recipes and resources
- Attributes
- ERB templates
- Package and service management
- Users, groups, directories, files, and links
- Notifications
- Idempotency
- Policyfiles
- Test Kitchen
- InSpec validation
- Automated Cookstyle validation

## Next project

After this Chef project is understood and tested, the same required server state can be recreated with Ansible. Comparing the Chef and Ansible results will demonstrate a complete Chef-to-Ansible migration.

## Safety

This is a personal learning project. It does not contain employer code, SAP software, private infrastructure details, or credentials. Run it only on a disposable Ubuntu container, virtual machine, or authorized test server.
