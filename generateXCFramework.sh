#!/bin/sh

### IMPORTANTE ###
##### Como usar: sh build-project.sh --target=TARGET ######
#### Siendo Target el target del proyecto ios que se quiere construir ####
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

for arg in "$@"
do
    case $arg in
    -t=* |--target=*)
        TARGET="${arg#*=}"
        shift # Remove --target= from processing
        ;;
    esac
done

#Modificar la arquitectura en caso de ser necesario
ARCH_SIMULATOR="x86_64 arm64"
ARCH_IPHONE="arm64"


cd $TARGET
PROJECT_DIR=$PWD
XCFRAMEWORK_OUPUT=${PROJECT_DIR}/../$TARGET.xcframework
BUILD_DIR=${PROJECT_DIR}/build
IPHONEOSIMULATOR_FRAMEWORK=${BUILD_DIR}/Release-iphonesimulator
IPHONEOS_FRAMEWORK=${BUILD_DIR}/Release-iphoneos

updateDependencies(){
    cd $PROJECT_DIR
    xcodebuild -resolvePackageDependencies
   
}

convert_to_dynamic() {
perl -i -p0e 's/type: .static,//g' $PROJECT_DIR/Package.swift
perl -i -p0e 's/type: .dynamic,//g' $PROJECT_DIR/Package.swift
perl -i -p0e 's/(library[^,]*,)/$1 type: .dynamic,/g' $PROJECT_DIR/Package.swift
}

convert_to_normal() {
perl -i -p0e 's/type: .static,//g' $PROJECT_DIR/Package.swift
perl -i -p0e 's/type: .dynamic,//g' $PROJECT_DIR/Package.swift
perl -i -p0e 's/(library[^,]*,)/$1 /g' $PROJECT_DIR/Package.swift
}

create_frameworks(){

for PLATFORM in "iOS" "iOS Simulator"; do

    case $PLATFORM in
    "iOS")
    RELEASE_ARCH="Release-iphoneos"
    ARCHS=$ARCH_IPHONE
    ;;
    "iOS Simulator")
    RELEASE_ARCH="Release-iphonesimulator"
    ARCHS=$ARCH_SIMULATOR
    ;;
    esac

    ARCHIVE_PATH=$BUILD_DIR/$RELEASE_ARCH
    xcodebuild archive -workspace $PROJECT_DIR -scheme $TARGET \
            -destination "generic/platform=$PLATFORM" \
            -archivePath $ARCHIVE_PATH \
            -derivedDataPath $BUILD_DIR \
            ARCHS="$ARCHS" \
            SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    FRAMEWORK_PATH="$ARCHIVE_PATH.xcarchive/Products/usr/local/lib/$TARGET.framework"
    MODULES_PATH="$FRAMEWORK_PATH/Modules"
    mkdir -p $MODULES_PATH

    BUILD_PRODUCTS_PATH="$BUILD_DIR/Build/Intermediates.noindex/ArchiveIntermediates/$TARGET/BuildProductsPath"
    RELEASE_PATH="$BUILD_PRODUCTS_PATH/$RELEASE_ARCH"
    SWIFT_MODULE_PATH="$RELEASE_PATH/$TARGET.swiftmodule"
    RESOURCES_BUNDLE_PATH="$RELEASE_PATH/${TARGET}_${TARGET}.bundle"

    # Copy Swift modules
    if [ -d $SWIFT_MODULE_PATH ]
    then
        cp -r $SWIFT_MODULE_PATH $MODULES_PATH
    else
        # In case there are no modules, assume C/ObjC library and create module map
        echo "module $TARGET { export * }" > $MODULES_PATH/module.modulemap
        perl -lne 'print $1 if /\<'${TARGET}'\/(\S+.h)/' $TARGET/$TARGET    .h | \
        xargs -I {} find . -name "{}" -print | \
        xargs -I {} cp {} $HEADERS_PATH/.
        cp $TARGET/$TARGET.h $HEADERS_PATH/.
    fi
        


    # Copy resources bundle, if exists
    if [ -e $RESOURCES_BUNDLE_PATH ]
    then
        cp -r $RESOURCES_BUNDLE_PATH $FRAMEWORK_PATH
    fi

    #Delete Frameworks Folder
    if [ -e $FRAMEWORK_PATH/Frameworks ]
    then
        rm -rf $FRAMEWORK_PATH/Frameworks
    fi

done

}

ready_to_fail(){
xcodebuild  -workspace $PROJECT_DIR -scheme $TARGET \
            -destination "generic/platform=iOS" \
            -derivedDataPath $BUILD_DIR \
            ARCHS="$ARCH_IPHONE" \
            SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

}


generate_xcframework() {
    cd $BUILD_DIR
     (xcodebuild -create-xcframework \
     -framework Release-iphoneos.xcarchive/Products/usr/local/lib/$TARGET.framework \
     -framework Release-iphonesimulator.xcarchive/Products/usr/local/lib/$TARGET.framework \
     -allow-internal-distribution -output $XCFRAMEWORK_OUPUT || (echo -e "\n\n${RED}CLEAN and BUILD for Target '${TARGET}' => FAILED\n\n${NC}" && exit 1)) &&  echo -e "\n\n${GREEN}CLEAN and BUILD for Target '${TARGET}' => SUCCEEDED\n\n${NC}"
}


build_project () {
    rm -rf $BUILD_DIR
    updateDependencies
    convert_to_dynamic
    (ready_to_fail && create_frameworks) || create_frameworks
    generate_xcframework
    convert_to_normal
}

build_project
