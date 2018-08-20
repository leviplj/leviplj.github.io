#!/bin/bash

set -e

DEPLOY_REPO="https://${DEPLOY_BLOG_TOKEN}@github.com/leviplj/leviplj.github.io.git"
DEPLOY_BRANCH=master

function deploy {
	echo "deploying changes"

	if [ -z "$TRAVIS_PULL_REQUEST" ]; then
	    echo "except don't publish site for pull requests"
	    exit 0
	fi

	if [ "$TRAVIS_BRANCH" != "gh-pages" ]; then
	    echo "except we should only publish the gh-pages branch. stopping here"
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

	if git diff-index --quiet HEAD --; then
		echo "No Changes to Commit"
		exit 0
	else

		echo "Commiting changes"
		git commit -m "Lastest site built on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to github"
		git push $DEPLOY_REPO $DEPLOY_BRANCH:$DEPLOY_BRANCH
	fi
}

deploy
