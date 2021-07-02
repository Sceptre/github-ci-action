#!/bin/bash

function parseInputs {
  # Required inputs
  if [[ "${INPUT_SCEPTRE_SUBCOMMAND}" != "" ]]; then
    sceptreSubcommand=${INPUT_SCEPTRE_SUBCOMMAND}
  else
    echo "ERROR: Input sceptre_subcommand cannot be empty!"
    exit 1
  fi

  # Optional inputs
  if [[ "${INPUT_SCEPTRE_VERSION}" != "" ]]; then
    if [[ "${INPUT_SCEPTRE_VERSION}" =~ ^2[.][0-9][.][0-9]$ ]]; then
      sceptreVer=${INPUT_SCEPTRE_VERSION}
    else
      echo "ERROR: Unsupported sceptre version"
      exit 1
    fi
  else
    if [[ "${INPUT_SCEPTRE_PIPFILE}" == "" && "${INPUT_SCEPTRE_REQUIREMENTS}" == "" ]]; then
      echo "ERROR: Input sceptre_version cannot be empty!"
      exit 1
    else
      echo "WARNING: Sceptre version not specified, so it's assumed that it"
      echo "-------  is specified in the Pipfile or requirements file."
    fi
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

  if [[ "${INPUT_SCEPTRE_PIPFILE}" != "" ]] \
     && [[   "${INPUT_SCEPTRE_REQUIREMENTS}" != "" \
          || "${INPUT_SCEPTRE_PLUGINS}" != "" \
          || "${INPUT_SCEPTRE_TROPOSPHERE_VERSION}" != "" \
          || "${INPUT_SCEPTRE_VERSION}" != "" ]]; then
        echo "WARNING: Detected Pipfile and at least one other method for specifying"
        echo "-------  dependencies/versions. Only the Pipfile will be installed."
        echo "-------  Consider only specifying the dependencies/versions in the Pipfile."
    fi
  fi

  if [[ "${INPUT_SCEPTRE_PIPFILE}" != "" || "${INPUT_SCEPTRE_REQUIREMENTS}" != "" ]]; then

    if [[ "${INPUT_SCEPTRE_PLUGINS}" != "" ]]; then
        echo "WARNING: Detected Pipfile and/or requirements file and Sceptre plugins."
        echo "-------  Consider only specifying the Sceptre plugins in either file."
    fi

    if [[ "${INPUT_SCEPTRE_TROPOSPHERE_VERSION}" != "" ]]; then
      echo "WARNING: Detected Pipfile and/or requirements file and Troposhere version."
      echo "-------  Consider only specifying the Troposphere version in either file."
    fi

    if [[ "${INPUT_SCEPTRE_VERSION}" != "" ]]; then
      echo "WARNING: Detected Pipfile and/or requirements file and a Sceptre version."
      echo "-------  Consider only specifying the Sceptre version in the Pipfile."
    fi

  fi
}

function installDeps {

  if [[ "${INPUT_SCEPTRE_PIPFILE}" != "" ]]; then
    echo "Installing Pipenv"
    if [[ "${INPUT_SCEPTRE_PIPENV_VERSION}" != "" ]]; then
      pip install --no-input pipenv==$INPUT_SCEPTRE_PIPENV_VERSION
    else
      pip install --no-input pipenv
    fi
    echo "Installing Python Pipfile"
    (cd $(dirname ${GITHUB_WORKSPACE}/${INPUT_SCEPTRE_PIPFILE}) && pipenv install)
  fi

  if [[ "${INPUT_SCEPTRE_REQUIREMENTS}" != "" ]]; then
    echo "Installing Python requirements"
    pip install --no-input --requirement ${GITHUB_WORKSPACE}/${INPUT_SCEPTRE_REQUIREMENTS}
  fi

  if [[ "${INPUT_SCEPTRE_PLUGINS}" != "" ]]; then
    echo "Installing Sceptre plugins"
    pip install --no-input ${INPUT_SCEPTRE_PLUGINS}
  fi

  if [[ "${INPUT_SCEPTRE_TROPOSPHERE_VERSION}" != "" ]]; then
    echo "Installing Troposphere version $sceptreTroposphereVer"
    pip install --no-input troposphere==$sceptreTroposphereVer
  fi

  if [[ "${INPUT_SCEPTRE_VERSION}" != "" ]]; then
    echo "Installing Sceptre version $sceptreVer"
    pip install --no-input sceptre==$sceptreVer
  fi
}


function main {
  parseInputs
  installDeps

  cd ${GITHUB_WORKSPACE}/${sceptreDir}

  if [[ "${INPUT_SCEPTRE_PIPFILE}" != "" ]]; then
    pipenv run sceptre $sceptreSubcommand
  else
    sceptre $sceptreSubcommand
  fi
}

main "${*}"
