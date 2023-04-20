#!/bin/bash

function parseInputs {
  # Required inputs
  if [[ "${INPUT_SCEPTRE_SUBCOMMAND}" != "" ]]; then
    sceptreSubcommand=${INPUT_SCEPTRE_SUBCOMMAND}
  else
    echo "Input sceptre_subcommand cannot be empty!"
    exit 1
  fi

  # Optional inputs
  sceptreVer='4.0.2'
  if [[ "${INPUT_SCEPTRE_VERSION}" != "" ]]; then
      sceptreVer=${INPUT_SCEPTRE_VERSION}
  else
    echo "Input sceptre_version cannot be empty!"
    exit 1
  fi

  sceptreDir="."
  if [[ -n "${INPUT_SCEPTRE_DIRECTORY}" ]]; then
    sceptreDir=${INPUT_SCEPTRE_DIRECTORY}
  fi

  sceptreTroposphere=0
  if [[ "${INPUT_SCEPTRE_TROPOSPHERE}" != "" ]]; then
    if [[ "${INPUT_SCEPTRE_TROPOSPHERE}" == "false" ]]; then
      sceptreTroposphere=0
    elif [[ "${INPUT_SCEPTRE_TROPOSPHERE}" == "true" ]]; then
      sceptreTroposphere=1
    else
      echo "Invalid input for sceptre_troposphere, must be 'true' or 'false'"
      exit 1
    fi
  else
      echo "Input sceptre_troposphere cannot be empty!"
      exit 1
  fi

  sceptreTroposphereVer='4.3.2'
  if [[ "${INPUT_SCEPTRE_TROPOSPHERE_VERSION}" != "" ]]; then
      sceptreTroposphereVer=${INPUT_SCEPTRE_TROPOSPHERE_VERSION}
  else
    echo "Input sceptre_troposphere_version cannot be empty!"
    exit 1
  fi

}

function installDeps {
  if [[ "${sceptreTroposphere}" == 1 ]]; then
    echo "Installing Troposphere"
    pip install --no-input troposphere==$sceptreTroposphereVer
  fi
  echo "Installing Sceptre"
  pip install --no-input sceptre==$sceptreVer
  if [[ "${INPUT_SCEPTRE_PLUGINS}" != "" ]]; then
    echo "Installing Sceptre plugins"
    pip install --no-input ${INPUT_SCEPTRE_PLUGINS}
  fi
}


function main {
  parseInputs
  installDeps

  cd ${GITHUB_WORKSPACE}/${sceptreDir}

  sceptre $sceptreSubcommand
}

main "${*}"
