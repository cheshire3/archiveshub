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


### Git


I'd recommend the [subtree merging][3] strategy, rather than [submodules][2].
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


### Mercurial


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


Licensing
---------

Copyright © 2005-2013, the [University of Liverpool][*]. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

 * Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
 * Neither the name of the [University of Liverpool][*] nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


[*]: http://liv.ac.uk

