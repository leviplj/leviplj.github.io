#!/bin/bash

set -e

DEPLOY_REPO="https://${DEPLOY_BLOG_TOKEN}@github.com/leviplj/leviplj.github.io.git"

function main {
	deploy
}

function deploy {
	echo "deploying changes"

	if [ -z "$TRAVIS_PULL_REQUEST" ]; then
	    echo "except don't publish site for pull requests"
	    exit 0
	fi

	if [ "$TRAVIS_BRANCH" != "master" ]; then
	    echo "except we should only publish the master branch. stopping here"
	    exit 0
	fi

	echo "Lastest site built on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to github"
	echo $DEPLOY_REPO

	echo "Adding changes"
	cd _site
	git config --global user.name "Travis CI"
    git config --global user.email leviplj@gmail.com

	git add -A .
	git status

	echo "Commiting changes"
	git commit -m "Lastest site built on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to github"
	git push $DEPLOY_REPO gh-pages:gh-pages
}

main