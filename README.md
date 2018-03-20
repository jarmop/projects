# projects
A collection of projects. (Very early prototypes.)

To split a project into a new repository:  
https://help.github.com/articles/splitting-a-subfolder-out-into-a-new-repository/

```
git clone https://github.com/jarmop/projects.git
cd projects
git filter-branch --prune-empty --subdirectory-filter train master
git remote -v
git remote set-url origin https://github.com/jarmop/train.git
git remote -v
git push -u origin master

```
