# Sceptre GitHub Action

This GitHub action allows you to simply executre Sceptre commands within Github actions, without needing to handle any installation of pip modules.

The action supports all commands and template types, including Troposphere.

It is possible to use this action on a self-hosted runner, provided the runner has docker installed. See the [GitHub action Docs](<https://help.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners#requirements-for-self-hosted-runner-machines>) for more info.

## Compatibility

Requires:

- Sceptre Version >2
- Troposphere Version >2 (If used)

## Environment Variables

To use this action you must specify the following environment variables for the runner used to execute the action:

```none
AWS_ACCESS_KEY_ID
# Specifies an AWS access key associated with an IAM user or role.

AWS_SECRET_ACCESS_KEY
# Specifies the secret key associated with the access key. This is essentially the "password" for the access key.
```

Optionally, you can provide these environment variables:

```none
AWS_DEFAULT_REGION
# Specifies the AWS Region to send the request to. Only required if you haven't specified this in your stack config files.
```

## Usage

Here are two quick examples for some common workflows. Both workflows assume a Sceptre structure like so:
```none
.
├── config
│   ├── config.yaml
│   ├── dev
│   │   └── ecr.yaml
│   └── prod
│       └── ecr.yaml
└── templates
    └── ecr.yaml
```

```yaml
# Function: Validate stacks against the 'dev' environment
# Trigger: Pull Request created
name: 'Sceptre GitHub Actions'
on:
  - pull_request
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
jobs:
  sceptre:
    name: 'Sceptre'
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master

      - name: 'Sceptre Validate'
        uses: rurquhart/sceptre-action@master
        with:
          sceptre_version: '2.3.0'
          sceptre_subcommand: 'validate dev'
```

```yaml
# Function: Validate stacks, then launch all stacks in the 'dev' environment
# Trigger: Push/Merge to 'develop' branch
name: 'Sceptre GitHub Actions'
on:
  push:
    branches:
      - develop
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
jobs:
  sceptre:
    name: 'Sceptre'
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout'
        uses: actions/checkout@master

      - name: 'Sceptre Validate'
        uses: rurquhart/sceptre-action@master
        with:
          sceptre_version: '2.3.0'
          sceptre_subcommand: 'validate dev'

      - name: 'Sceptre launch'
        uses: rurquhart/sceptre-action@master
        with:
          sceptre_version: '2.3.0'
          sceptre_subcommand: 'launch -y dev'
```

## Further examples

For further examples and to see this action used, please look at [this repo](<https://github.com/Rurquhart/sceptre-action-examples>).

## References

- [Sceptre Documentation](<https://sceptre.cloudreach.com/2.3.0/>)
- [GitHub Actions Documentation](<https://help.github.com/en/actions>)
