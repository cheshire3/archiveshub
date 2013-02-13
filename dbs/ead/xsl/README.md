ead-xslt
========

Description
-----------

XSLT used by [cheshire3-archives][1], the [Archives Hub][2] and related projects to
transform EAD

[1]: https://github.com/cheshire3/cheshire3-archives
[2]: http://archiveshub.ac.uk



Installation
------------

This section provides some pointers on how to integrate into other projects in
various version control systems. `path/to/xslt` represent the path where you
want to embed the XSLT relative to (and assuming you will run the commands from)
your project's root.


Git
~~~

I'd recommend the [subtree merging][3] strategy, rather than submodules [2].
I'd also recommend reading up on [subtree merging][4] before blindly continuing
with the following steps; I'm far from an expert in git, and you should really
read up on what you're getting into...

```shell
git remote add xslt_remote git@github.com:cheshire3/ead-xslt.git
git fetch xslt_remote
git checkout -b xslt_branch xslt_remote/master
git read-tree --prefix=path/to/xslt -u xslt_branch
```

[3]: http://git-scm.com/book/en/Git-Tools-Subtree-Merging
[4]: http://git-scm.com/book/en/Git-Tools-Submodules


Mercurial
~~~~~~~~~

Create a [Mercurial subrepository][5]. I'd highly recommend reading up on
[Mercurial Subrepositories][5] before blindly continuing with the following
steps; I'm a relative novice with Mercurial, and you should **really** read up
on what you're getting into...

```shell
echo "nested = [git]git://github.com/cheshire3/ead-xslt.git" > .hgsub
hg add .hgsub
git clone git://github.com/cheshire3/ead-xslt.git path/to/xslt
hg commit -m "adding XSLT subrepository" 
```

[5]: http://mercurial.selenic.com/wiki/Subrepository
