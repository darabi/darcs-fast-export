export DARCS_EMAIL="user@example.com"
export PATH="$(pwd)/..:$PATH"

_drrec()
{
	darcs rec --ignore-times "$@"
}

_drrec_multiline()
{
	echo -e "`LANG= LC_ALL= date +"%a %b %d %H:%M:%S %Z %Y"`
$DARCS_EMAIL
$@" | darcs rec --ignore-times -a --pipe .
}

create_darcs()
{
	rm -rf $1
	mkdir -p $1
	cd $1
	darcs init $2
	echo A > file
	darcs add file
	_drrec -a -m A
	cd ..
	rm -rf $1.tmp
	darcs get $1 $1.tmp
	cd $1
	echo B > file
	_drrec -a -m B
	cd ../$1.tmp
	echo C > file
	_drrec -a -m C
	cd ../$1
	darcs pull -a ../$1.tmp
	echo D > file
	_drrec_multiline "first line
second line
third line"
	darcs tag 1.0
	echo e > file
	_drrec -a -m e
	echo f > file
	_drrec --author="���� <$DARCS_EMAIL>" -a -m f
	echo g > file
	_drrec --author="" -a -m g
	cp ../data/hungarian.gif .
	darcs add hungarian.gif
	_drrec -a -m "add a binary file"
	rm file
	echo test > file2
	darcs add file2
	_drrec -a -m "replace file with file2"
	touch file3
	darcs add file3
	_drrec -a -m "add empty file"
	rm file3
	_drrec -a -m "remove file"
	cd ..
}

create_git()
{
	rm -rf $1
	mkdir -p $1
	cd $1
	git init $2
	echo A > file
	git add file
	git commit -a -m A
	echo B > file
	git commit -a -m B
	git checkout -b tmp HEAD~1
	echo C > file
	git commit -a -m C
	git checkout master
	git merge tmp
	echo D > file
	echo "first line
second line
third line" | git commit -a -F -
	git branch -d tmp
	git tag 1.0
	echo e > file
	git commit -a -m e
	echo f > file
	git config i18n.commitencoding ISO-8859-2
	git commit --author="���� <$DARCS_EMAIL>" -a -m f
	cp ../data/hungarian.gif .
	git add hungarian.gif
	git commit -a -m "add a binary file"
	rm file
	echo test > file2
	git add file2
	git commit -a -m "replace file with file2"
	touch file3
	git add file3
	git commit -a -m "add empty file"
	rm file3
	git commit -a -m "remove file"
	cd ..
}

diff_git()
{
	rm -rf $1.git.nonbare
	git clone -q $1.git $1.git.nonbare
	diff --exclude _darcs --exclude .git --exclude '*-darcs-backup*' -Naur $1.git.nonbare $1
	return $?
}

diff_importgit()
{
	diff --exclude _darcs --exclude .git --exclude '*-darcs-backup*' -Naur $1 $1.darcs
	return $?
}

diff_importdarcs()
{
	diff --exclude _darcs --exclude '*-darcs-backup*' -Naur $1 $2
	return $?
}

diff_bzr()
{
	cd $1.bzr/master
	bzr update
	cd - >/dev/null
	diff --exclude _darcs --exclude .bzr --exclude '*-darcs-backup*' -Naur $1.bzr/master $1
	return $?
}

diff_hg()
{
	diff --exclude _darcs --exclude .hg --exclude '*-darcs-backup*' -Naur $1.hg $1
	return $?
}

die()
{
	echo "fatal: $@"
	exit 1
}

upd_file_darcs()
{
	cd $1
	echo $3 > $2
	_drrec -a -m "updated '$2' to '$3'"
	cd ..
}

upd_file_git()
{
	cd $1
	echo $3 > $2
	git commit -a -m "updated '$2' to '$3'"
	cd ..
}
