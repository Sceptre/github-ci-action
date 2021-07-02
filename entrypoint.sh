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
  sceptreVer='2.5.0'
  if [[ "${INPUT_SCEPTRE_VERSION}" != "" ]]; then
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

  sceptreTroposphereVer='2.6.0'
  if [[ "${INPUT_SCEPTRE_TROPOSPHERE_VERSION}" != "" ]]; then
    if [[ "${INPUT_SCEPTRE_TROPOSPHERE_VERSION}" =~ ^2[.][0-9][.][0-9]$ ]]; then
      sceptreTroposphereVer=${INPUT_SCEPTRE_TROPOSPHERE_VERSION}
    else
      echo "Unsupported troposphere version, must be >2.0.0"
      echo "Version entered: ${INPUT_SCEPTRE_TROPOSPHERE_VERSION}"
      exit 1
    fi
  else
    echo "Input sceptre_troposphere_version cannot be empty!"
    exit 1
  fi

  if [[ "${INPUT_SCEPTRE_REQUIREMENTS}" != "" && "${INPUT_SCEPTRE_PIPFILE}" != "" ]]; then
    echo "WARNING: Detected Pipfile and requirements file"
    echo "-------  Consider only specifying Python dependencies in one or the other"
  fi

  if [[ "${INPUT_SCEPTRE_PIPFILE}" != "" || "${INPUT_SCEPTRE_REQUIREMENTS}" != "" ]]; then

    if [[ "${INPUT_SCEPTRE_PLUGINS}" != "" ]]; then
        echo "WARNING: Detected Pipfile and/or requirements file and Sceptre plugins"
        echo "-------  Consider only specifying the Sceptre plugins in either file"
    fi

    if [[ "${sceptreTroposphere}" == 1 ]]; then
      echo "WARNING: Detected Pipfile and/or requirements file and Troposhere version"
      echo "-------  Consider only specifying the Troposphere version in either file"
    fi

    if [[ "${INPUT_SCEPTRE_VERSION}" != "" ]]; then
      echo "WARNING: Detected Pipfile and/or requirements file and a Sceptre version"
      echo "-------  Consider only specifying the Sceptre version in the Pipfile"
    fi

  fi
}

function installDeps {
  cd ${GITHUB_WORKSPACE}

  if [[ "${INPUT_SCEPTRE_PIPFILE}" != "" ]]; then
    echo "Installing Pipenv"
    pip install pipenv
    echo "Installing Python Pipfile"
    cd $(dirname ${GITHUB_WORKSPACE}/${INPUT_SCEPTRE_PIPFILE}) && pipenv install
    pipenv shell
    cd ${GITHUB_WORKSPACE}
  fi

  if [[ "${INPUT_SCEPTRE_REQUIREMENTS}" != "" ]]; then
    echo "Installing Python requirements"
    pip install --no-input --requirement ${GITHUB_WORKSPACE}/${INPUT_SCEPTRE_REQUIREMENTS}
  fi

  if [[ "${INPUT_SCEPTRE_PLUGINS}" != "" ]]; then
    echo "Installing Sceptre plugins"
    pip install --no-input ${INPUT_SCEPTRE_PLUGINS}
  fi

  if [[ "${sceptreTroposphere}" == 1 ]]; then
    echo "Installing Troposphere version $sceptreTroposphereVer"
    pip install --no-input troposphere==$sceptreTroposphereVer
  fi

  if [[ "${INPUT_SCEPTRE_VERSION}" != "" ]] || ! command -v sceptre &> /dev/null; then
    echo "Installing Sceptre version $sceptreVer"
    pip install --no-input sceptre==$sceptreVer
  fi
}


function main {
  parseInputs
  installDeps

  cd ${GITHUB_WORKSPACE}/${sceptreDir}
  sceptre $sceptreSubcommand
}

main "${*}"
