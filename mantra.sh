#!/bin/bash

if [ -z "$1" ]
	then echo "no arguments" 
		exit 1
fi

#create tree-like maven structure
mkdir -p ~/IdeaProjects/"$1"/src/{main,test}/java/pl/michalak/adam/"${1,,}"
mkdir -p ~IdeaProjects/"$1"/src/main/resources

cd ~/IdeaProjects/"$1"/

#add staff to App.java and AppTest.java
cat <<-EOF > ~/IdeaProjects/"$1"/src/main/java/pl/michalak/adam/$1.java
package pl.michalak.adam;
/**
 * Main class of $1 application
 *
 * @author Adam Michalak
 */
class $1 {
public static void main(String[] args) {

    }
}
EOF

#ask for project description
read -p "Feed me short project description: " description

#add minimal pom.xml
set +x
curl https://gist.githubusercontent.com/LIttleAncientForestKami/c9b185c123fc97f6022861f645766aa5/raw/45db276f570fcca357fbcf36b6209517c69c6427/pom.xml | sed s/pl.lafk/pl.michalak.adam/g | sed s/#APP/$1/g | sed s/#NAME/"$1"/g | sed s/#DESC/"$description"/g | sed s/lafk.pl/"github.com\/michalakadam"/g | sed s/"#FQN of your MainClass"/pl.michalak.adam.$1/g > pom.xml

#create gitignore
curl https://www.gitignore.io/api/java,intellij > .gitignore
echo "*.iml" >> .gitignore
echo "target/" >> .gitignore
echo ".idea/" >> .gitignore

#create mailmap
echo "Adam Michalak <adam.michalak.dev@gmail.com>" > .mailmap

#Initialize empty git repository in the project's folder
git init

#Add readme.md file with a project name and description
touch README.md
#echo "${*^^}" >> README.md
cat <<-EOF >> README.md
# ${1^^}

##### $description
EOF

#Add estimates.md for future goal specification
cat <<-EOF >> estimates.md
# $1
#
# $description
|Date  |Pesimistic|Realistic|Optimistic|
:-----:|:--------:|:--------|----------:
EOF

#Enable user to add remote repository
read -p "Do you want to track remote repository?[Y/n] " repoAnswer
if [ "$repoAnswer" = "Y" ] || [ "$repoAnswer" = "y" ] || [ "$repoAnswer" = "" ]
then 
read -p "Feed me with link to the repository: (press q to quit) " repoLink
    #enable user to quit here
    if [ "$repoLink" = "q" ]
    then
    echo "Quitting connection to remote repository"
    else
    git remote add origin $repoLink
    fi
fi

#Initial commit
git add .
git commit -m "Initial commit with pom, readme and git repo initialized"
git checkout -b development

#recompile pom.xml and create target folder
mvn install

#Open project in Intellij IDEA
read -p "Do you want to open this project in Intellij?[Y/n] " ideAnswer
    if [ "$ideAnswer" = "Y" ] || [ "$ideAnswer" = "y" ] || [ "$ideAnswer" = "" ]
    then
    //snap/intellij-idea-community/95/bin/idea.sh pom.xml & 
fi

echo "NEW PROJECT INITIALIZED SUCCESSFULLY"
