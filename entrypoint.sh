#!/bin/bash

function parseInputs {
  # Required inputs
  if [ "${INPUT_SCEPTRE_SUBCOMMAND}" != "" ]; then
    sceptreSubcommand=${INPUT_SCEPTRE_SUBCOMMAND}
  else
    echo "Input sceptre_subcommand cannot be empty!"
    exit 1
  fi

  # Optional inputs
  sceptreVer='2.3.0'
  if [ "${INPUT_SCEPTRE_VERSION}" != "" ]; then
    if [[ "${INPUT_SCEPTRE_VERSION}" =~ ^2[.][0-9][.][0-9]$ ]]; then
      sceptreVer=${INPUT_SCEPTRE_VERSION}
    else
      echo "Unsupported sceptre version"
      exit 1
    fi
  else
    echo "Input sceptre_version cannot be empty!"
    exit 1
  fi

  sceptreDir=''
  if [ "${INPUT_SCEPTRE_DIRECTORY}" != ""]; then
    sceptreDir=${INPUT_SCEPTRE_DIRECTORY}
  else
    sceptreDir=""
  fi

  sceptreTroposphere=0
  if [ "${INPUT_SCEPTRE_TROPOSPHERE}" != "" ]; then
    if [ "${INPUT_SCEPTRE_TROPOSPHERE}" == "false" ]; then
      sceptreTroposphere=0
    elif [ "${INPUT_SCEPTRE_TROPOSPHERE}" == "true" ]; then
      sceptreTroposphere=1
    else
      echo "Invalid input for sceptre_troposphere, must be 'true' or 'false'"
      exit 1
    fi
  else
      echo "Input sceptre_troposphere cannot be empty!"
      exit 1
  fi

  sceptreTropospherVer='2.6.0'
  if [ "${INPUT_SCEPTRE_TROPOSPHERE_VERSION}" != "" ]; then
    if [[ "${INPUT_SCEPTRE_TROPOSPHERE_VERSION}" =~ ^2[.][0-9][.][0-9]$ ]]; then
      sceptreTropospherVer=${INPUT_SCEPTRE_TROPOSPHERE_VERSION}
    else
      echo "Unsupported sceptre version, must be >2.0.0"
      exit 1
    fi
  else
    echo "Input sceptre_version cannot be empty!"
    exit 1
  fi

}

function installDeps {
  if [ "${sceptreTroposphere}" == 1 ]; then
    echo "Installing Troposphere"
    pip install --no-input troposphere==$sceptreTropospherVer
  fi
  echo "Installing Sceptre"
  pip install --no-input sceptre==$sceptreVer
}


function main {
  parseInputs
  installDeps

  if [ "${sceptreDir}" != "" ]; then
    cd sceptreDir
  fi

  sceptre $sceptreSubcommand
}

main "${*}"
