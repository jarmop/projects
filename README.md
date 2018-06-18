# projects
A collection of projects. (Very early prototypes.)

## To split project into a new repository:  
https://help.github.com/articles/splitting-a-subfolder-out-into-a-new-repository/

For example a project named "train":

Step 1. Filter out the project:
```
git clone https://github.com/jarmop/projects.git
cd projects
git filter-branch --prune-empty --subdirectory-filter train master
```
Create new train repository on Github before the next step.

Step 2. Set remote url to the new repository:
```
git remote set-url origin https://github.com/jarmop/train.git
git push -u origin master
```

To check the remote is correct:
```
git remote -v
```
