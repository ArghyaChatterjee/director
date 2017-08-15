#!/bin/bash
set -ex

scriptDir=$(cd $(dirname $0) && pwd)


appName=Director
bundleDir=$scriptDir/$appName.app
superbuildInstallDir=$scriptDir/../../build/install

if [ ! -d "$superbuildInstallDir" ]; then
  superbuildInstallDir=$scriptDir/../../../build/install
fi

versionString=$($superbuildInstallDir/bin/directorPython -c 'import director.version as ver; print ver.gitDescribe()')

packageName=director-$versionString-mac

######
libDir=$bundleDir/Contents/MacOS/lib
binDir=$bundleDir/Contents/MacOS/bin
sitePackagesDir=$libDir/python2.7/site-packages

rm -rf $bundleDir
cp -r $scriptDir/bundle_template.app $bundleDir

# depending on build options the share directory might not exist already
mkdir -p $superbuildInstallDir/share

cp -r $superbuildInstallDir/{bin,lib,include,share} $bundleDir/Contents/MacOS/
cp $(which python) $binDir/
touch $binDir/qt.conf

mkdir -p $sitePackagesDir
cp -r /usr/local/opt/vtk7/lib/python2.7/site-packages/vtk $sitePackagesDir/
cp -r /usr/local/lib/python2.7/site-packages/numpy $sitePackagesDir/
cp -r /usr/local/lib/python2.7/site-packages/scipy $sitePackagesDir/
cp -r /usr/local/lib/python2.7/site-packages/yaml $sitePackagesDir/
cp -r /usr/local/lib/python2.7/site-packages/lxml $sitePackagesDir/


python $scriptDir/fixup_mach_o.py $superbuildInstallDir $bundleDir $libDir

# remove broken symlink to homebrew python site-packages
rm $libDir/Python.framework/Versions/Current/lib/python2.7/site-packages

cd $scriptDir
mkdir $packageName
mv $bundleDir $packageName/
cd $packageName
ln -s $appName.app/Contents/MacOS/bin
ln -s $appName.app/Contents/MacOS/lib
ln -s $appName.app/Contents/MacOS/include
ln -s $appName.app/Contents/MacOS/share

# remove headers
#find $appName.app -name \*.h | xargs rm

cd ..
tar -czf $packageName.tar.gz $packageName
