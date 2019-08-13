#!/bin/bash

#DEFAULT VALUES
projectsDirectory=~/IdeaProjects
author="Adam Michalak"
author_mail="adam.michalak.dev@gmail.com"
repoUrl="github.com\/michalakadam"
groupDomain="dev.michalak.adam"
groupProjectDirectory="dev/michalak/adam"

#ask for project name
correctInputFlag=0
while [[ "$correctInputFlag" -eq 0 ]]; do
    read -p "Name of the project: " projectName
    if [[ -z "$projectName" ]]; then
        echo "No arguments, try again."
    else
        correctInputFlag=$(( correctInputFlag+1 ))
    fi
done

#create project folder if it does not already exist
if [[ -d "$projectsDirectory"/"$projectName" ]]; then
    echo "Project with such a name already exist. Terminating..."
    exit 1
else
    mkdir -p "$projectsDirectory"/"$projectName"
fi
printf "Project directory successfully created.\n\n"

read -p "Feed me short project description: " description

#create tree-like maven structure
mkdir -p "$projectsDirectory"/"$projectName"/src/{main,test}/java/"$groupProjectDirectory"/"${projectName}"
mkdir -p "$projectsDirectory"/"$projectName"/src/main/resources
printf "Standard maven folder structure of the project generated.\n"

#add minimal pom.xml
sed -e "s/GROUP_ID/$groupDomain/g" -e "s/PROJECT_NAME/$projectName/g" -e "s/PROJECT_DESCRIPTION/$description/g" -e "s/GROUP_URL/$repoUrl/g" -e "s/MAIN_CLASS_PATH/$groupDomain\.$projectName/g" ./templates/pom > "$projectsDirectory"/"$projectName"/pom.xml
printf "Adding pom... DONE.\n"

#add template main class of the program
sed -e "s/PACKAGE_NAME/$groupDomain/g" -e "s/PROJECT_NAME/$projectName/g" -e "s/AUTHOR_NAME/$author/g" ./templates/mainclass > "$projectsDirectory"/"$projectName"/src/main/java/"$groupProjectDirectory"/$projectName.java
printf "Adding main class of the program in $projectName/src/main/java/$groupProjectDirectory/$projectName.java... DONE.\n"

#Add readme.md file template
sed -e "s/PROJECT_NAME/$projectName/g" -e "s/DESCRIPTION/$description/g" -e "s/REPO_URL/$repoUrl/g" -e "s/MAIL/$author_mail/g" ./templates/readme > "$projectsDirectory"/"$projectName"/README.md
printf "Adding README... DONE.\n"

#Add estimates.md for future goal specification
now=$(date +"%d-%m-%Y")
sed -e "s/PROJECT_NAME/$projectName/g" -e "s/DESCRIPTION/$description/g" -e "s/DATE_TODAY/$now/g" ./templates/estimates > "$projectsDirectory"/"$projectName"/estimates.md
printf "Adding estimates... DONE.\n"

#copy precommit to project folder for further processing
cp ./templates/precommit "$projectsDirectory"/"$projectName"/precommit

#Navigate to project directory
cd "$projectsDirectory"/"$projectName"/

#create gitignore
curl https://www.gitignore.io/api/java,intellij > .gitignore
echo "*.iml" >> .gitignore
echo "target/" >> .gitignore
echo ".idea/" >> .gitignore
printf "Creating gitignore file... DONE.\n"

#create mailmap
echo "$author <$author_mail>" > .mailmap
printf "Creating mailmap file... DONE.\n"

#Initialize empty git repository in the project's folder
git init

#add git precommit hook in git repository
rm .git/hooks/pre-commit.sample
mv ./precommit .git/hooks/pre-commit
printf "Adding precommit hook to repository... DONE.\n"

#Enable user to add remote repository
read -p "Do you want to track remote repository?[Y/n] " repoAnswer
if [ "$repoAnswer" = "Y" ] || [ "$repoAnswer" = "y" ] || [ "$repoAnswer" = "" ]; then
    read -p "Feed me with link to the repository: (press q to quit) " repoLink
    #enable user to quit here
    if [ "$repoLink" = "q" ]; then
        echo "Quitting connection to remote repository"
    else
        git remote add origin $repoLink
    fi
fi

#Initial commit
git add .
git commit -m "initial commit with project template generated"
git checkout -b development

##Open project in Intellij IDEA - works on Linux only. Uncomment and change idea.sh location in order to use it.
#read -p "Do you want to open this project in Intellij?[Y/n] " ideAnswer
#    if [ "$ideAnswer" = "Y" ] || [ "$ideAnswer" = "y" ] || [ "$ideAnswer" = "" ]; then
#       //snap/intellij-idea-community/95/bin/idea.sh pom.xml &
#fi

printf "\nNEW PROJECT INITIALIZED SUCCESSFULLY"
