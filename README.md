# lpkg.sh
A package manager made in shell script. works on android. and is open-source.

you may ask what is this.
this is a package manager made in shell script.
it uses .pkg as its install package.


Do
```
lpkg help
```
for help with lpkg.

you also suggest me ideas to update or add features to this.
one issue is there is no dependecys yet so you will have to add some kind of lib or dependecy to your package.

to make a package you need zip and unzip

zip is for making the .pkg file

```
zip -o filename.pkg folder/*
```

unzip is for unziping the .pkg

if you get the error start.sh is not found then there is no start.sh to start it

to start a package or script inside the package do this

```
./lpkg.sh run package
```
if there is no start.sh do this

```
./lpkg.sh run package script.sh
```

thats all for this.
