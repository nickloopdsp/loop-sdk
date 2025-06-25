#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# 
# Usage example: /bin/bash ./make_publish_sdk.sh p (for npmpublish)

OUTPUT_DIRECTORY=".sdk"
packageversion=1.0.0
npmpublish=false;
npmlink=true;
createtag=false;
CWD=$(pwd);


declare package_version_mode=manual;

echo "Output directory: $OUTPUT_DIRECTORY"

while getopts ":lpavt:" opt; do
  case ${opt} in
    l ) # process option l
        npmlink=true
      ;;
    p ) # process option p
        npmpublish=true
        npmlink=false
        createtag=true
      ;;
    v ) # process option v
        packageversion=$OPTARG
        echo "Setting package version to $packageversion"
      ;;
    a ) # process option a
      package_version_mode=auto
      echo "changing package version mode to auto, will override package version provided in v"
      ;;
    t ) # process option t
        createtag=true
        echo "Will create Git tag after publishing"
      ;;
    \? ) echo -e "Usage:\n ./make_publish_sdk.sh [-l] to build then do npm link \n ./make_publish_sdk.sh [-p] to build then do npm npmpublish \n ./make_publish_sdk.sh [-a] to build then do auto increment version \n ./make_publish_sdk.sh [-t] to create Git tag"
        exit;
      ;;
  esac
done

# override package version when mode is auto
if [[ $package_version_mode == "auto" ]]; then
	echo "processing request in automatic mode"

  export NPM_TOKEN=$(cat ~/.npmrc | grep -o 'npm.pkg.github.com/:_authToken=.*' | sed 's/npm.pkg.github.com\/:_authToken=//g')

  #fetch and parse sdk meta tags from github package registry

  declare parsed_meta_tags=$(curl -s -H "Accept: application/vnd.github+json" -H "Authorization: token $NPM_TOKEN" \
  "https://api.github.com/repos/nickloopdsp/loop-sdk/packages/npm/loop-sdk/versions?page=1&per_page=1" | \
  awk -F ":" '$1 ~ /"name"/ {print $2}' | \
  sed 's/[" ,]//g')

  declare sdk_meta_response=$?

  if [ $sdk_meta_response -ne 0 ]; then
    echo "erorr while fetching meta tags for sdk"
    exit;

  elif [[ $parsed_meta_tags =~ (([0-9])*\.){2}([0-9])* ]]; then
    package_version=$parsed_meta_tags
    echo "current package version: $package_version"
    next_version=$(echo ${package_version} | awk -F "." -v OFS=\. '{$NF += 1; print}')
    echo "updating package version to version: $next_version"
    packageversion=$next_version

  else
    echo "invalid package version"
    exit;
  fi
fi

# delete the existing directory
rm -rf $OUTPUT_DIRECTORY

# Ensure the SDK directory exists
mkdir -p ${OUTPUT_DIRECTORY}

# Check if the server is running
curl -s http://localhost:3001/api/docs-json > /dev/null
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Cannot connect to API server at http://localhost:3001/api/docs-json."
    echo "Please ensure the NestJS development server is running before generating the SDK."
    exit 1
fi
echo "✅ API server is reachable. Proceeding with SDK generation."

# run generator
openapi-generator-cli generate \
  -i http://localhost:3001/api/docs-json \
  -g typescript-axios \
  -o ${OUTPUT_DIRECTORY} \
  --skip-validate-spec \
  -c openapigeneratorconfig.json
  
# After this point, the script will automatically exit if any command fails.
# No need for manual $? checks.

cd $OUTPUT_DIRECTORY

rm README.md

npm version $packageversion

npm install

# get current package version: npm pkg get version
# set package version: npm version 0.0.9
npm run build

printf "**/*\n!/dist/**/*" > .npmignore #shell

if [ "$npmpublish" = true ]; then 
    echo "🚀 Publishing npm package..."
    npm publish
    
    # Create Git tag after successful publish
    if [ "$createtag" = true ]; then
        echo "🏷️ Creating Git tag v$packageversion..."
        cd $CWD
        
        # Check if tag already exists
        if git rev-parse "v$packageversion" >/dev/null 2>&1; then
            echo "⚠️ Tag v$packageversion already exists. Skipping tag creation."
        else
            # Create and push the tag
            git tag -a "v$packageversion" -m "Release v$packageversion - SDK generated from API"
            git push origin "v$packageversion"
            echo "✅ Git tag v$packageversion created and pushed successfully."
        fi
    fi
else 
   echo "Not publishing. Performing a dry run for verification."
   npm publish --dry-run
fi

if [ "$npmlink" = true ]; then 
  echo "🔗 Running npm link..."
  npm link

  #after creating the link, now apply it to each repo
  # go back to initial directory so we have a reference
  cd $CWD
  
  FRONTEND_DIR="${CWD}/../loop-frontend"
  if [ -d "$FRONTEND_DIR" ]; then
    echo "Applying link to loop-frontend repo..."
    pushd "$FRONTEND_DIR" > /dev/null
    npm link @nickloopdsp/loop-sdk
    popd > /dev/null
    echo "✅ Link applied successfully."
  else
    echo "⚠️ Warning: Frontend directory not found at ${FRONTEND_DIR}"
  fi
fi