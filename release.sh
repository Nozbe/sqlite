#!/usr/bin/env bash
set -e
set -x

version=${1:?version (e.g. 3.36.0) is required}

echo "will update sqlite..."
echo "will use version $version"
echo "and release on npm as $version"
echo

if ! [[ -d "downloads" ]]; then
  mkdir downloads
fi

echo "downloading sqlite..."
# https://sqlite.org/2021/sqlite-amalgamation-3360000.zip
year="$(date +%Y)"

version_to_download_js="v = process.argv[1];
  pad0 = (str) => str.length == 1 ? str + 0 : str;
  [major, minor, patch, micro = '0'] = v.split('.');
  [major, pad0(minor), pad0(patch), pad0(micro)].join('')"

download_version=$(node -p "$version_to_download_js" "$version")
download_folder="sqlite-amalgamation-${download_version}"
download_file="sqlite-amalgamation-${download_version}.zip"
download_url="https://sqlite.org/${year}/${download_file}"
curl "$download_url" -o "downloads/${download_file}"

echo "removing old sqlite files..."
git rm -r sqlite-amalgamation-*

echo "unzipping sqlite files..."
unzip "downloads/${download_file}"

echo "committing files..."
git add "${download_folder}"
rm sqlite3
ln -s "${download_folder}" sqlite3
git add sqlite3

git commit -m "Updating src files for sqlite ${version}"

echo "tagging package.json..."
npm version "$version"

echo "release on npm..."
npm publish

echo "push to git..."
git push origin master
git push --tags
