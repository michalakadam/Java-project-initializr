#!/bin/bash

#DEFAULT VALUES
projectsDirectory=~/IdeaProjects
author="Adam Michalak"
mail="adam.michalak.dev@gmail.com"
url="github.com\/michalakadam"
group="dev.michalak.adam"
groupProjectDirectory="dev/michalak/adam"

#ask for project name
correctInputFlag=0
while [[ "$correctInputFlag" -eq 0 ]]
do
    read -p "Name of the project: " projectName
    if [[ -z "$projectName" ]]
        then
        echo "No arguments, try again."
        else
        correctInputFlag=$(( correctInputFlag+1 ))
    fi
done

#create project folder if it does not already exist
if [[ -d "$projectsDirectory"/"$projectName" ]]
    then
    echo "Project with such a name already exist. Terminating..."
    exit 1
    else
    mkdir -p "$projectsDirectory"/"$projectName"
fi

read -p "Feed me short project description: " description

#create tree-like maven structure
mkdir -p "$projectsDirectory"/"$projectName"/src/{main,test}/java/"$groupProjectDirectory"/"${projectName}"
mkdir -p "$projectsDirectory"/"$projectName"/src/main/resources

#add minimal pom.xml
sed -e "s/GROUP_ID/$group/g" -e "s/PROJECT_NAME/$projectName/g" -e "s/PROJECT_DESCRIPTION/$description/g" -e "s/GROUP_URL/$url/g" -e "s/MAIN_CLASS_PATH/$group\.$projectName/g" ./templates/pom > "$projectsDirectory"/"$projectName"/pom.xml

#add template main class of the program
sed -e "s/PACKAGE_NAME/$group/g" -e "s/PROJECT_NAME/$projectName/g" -e "s/AUTHOR_NAME/$author/g" ./templates/mainclass > "$projectsDirectory"/"$projectName"/src/main/java/"$groupProjectDirectory"/$projectName.java

#Add estimates.md for future goal specification
now=$(date +"%d-%m-%Y")
sed -e "s/PROJECT_NAME/$projectName/g" -e "s/DESCRIPTION/$description/g" -e "s/DATE_TODAY/$now/g" ./templates/estimates > "$projectsDirectory"/"$projectName"/estimates.md

#Move to project directory
cd "$projectsDirectory"/"$projectName"/

#create gitignore
curl https://www.gitignore.io/api/java,intellij > .gitignore
echo "*.iml" >> .gitignore
echo "target/" >> .gitignore
echo ".idea/" >> .gitignore

#create mailmap
echo "$author <$mail>" > .mailmap

#Initialize empty git repository in the project's folder
git init

#Add readme.md file with a project name and description
touch README.md
#echo "${*^^}" >> README.md
cat <<-EOF >> README.md
# ${projectName^^}

##### $description
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
