Pod::Spec.new do |s|
    s.name             = 'OpenCV-Dynamic'
    s.version          = '3.1.0'
    s.summary          = 'OpenCV (Computer Vision) for iOS as a dynamic library.'

    s.description      = <<-DESC
OpenCV: open source computer vision library
    Homepage: http://opencv.org
    Online docs: http://docs.opencv.org
    Q&A forum: http://answers.opencv.org
    Dev zone: http://code.opencv.org
    DESC

    s.homepage         = 'https://github.com/legoless/opencv-dynamic'
    s.license          = { :type => '3-clause BSD', :file => 'LICENSE' }
    s.authors          = 'opencv.org'
    s.source           = { :git => 'https://github.com/edc1591/opencv-ios.git', :tag => s.version.to_s }

    s.ios.deployment_target = "8.0"
    s.source_files = "opencv2.framework/Headers/**/*{.h,.hpp}"
    #s.public_header_files = "opencv2.framework/Headers/**/*{.h,.hpp}"
    s.preserve_paths = "opencv2.framework"
    #s.header_dir = "opencv2"
    #s.header_mappings_dir = "opencv2.framework/Versions/A/Headers/"
    s.vendored_frameworks = "opencv2.framework"
    s.requires_arc = false
    s.libraries = [ 'stdc++' ]
    s.frameworks = [
        "Accelerate",
        "AssetsLibrary",
        "AVFoundation",
        "CoreGraphics",
        "CoreImage",
        "CoreMedia",
        "CoreVideo",
        "Foundation",
        "QuartzCore",
        "UIKit"
    ]

    s.prepare_command = <<-CMD
        mkdir build-iphoneos
        cd build-iphoneos
        cmake -GXcode -DCMAKE_C_FLAGS=-fembed-bitcode -DCMAKE_CXX_FLAGS=-fembed-bitcode -DBUILD_SHARED_LIBS=ON -DCMAKE_MACOSX_BUNDLE=ON -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED=NO -DAPPLE_FRAMEWORK=ON -DCMAKE_INSTALL_PREFIX=install -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../platforms/ios/cmake/Toolchains/Toolchain-iPhoneOS_Xcode.cmake -DENABLE_NEON=ON ../
        xcodebuild -arch armv7 -arch armv7s -arch arm64 -sdk iphoneos -configuration Release -parallelizeTargets -jobs 4 ONLY_ACTIVE_ARCH=NO IPHONEOS_DEPLOYMENT_TARGET=8.0 -target ALL_BUILD build OTHER_CFLAGS='$(inherited) -Wno-implicit-function-declaration'
        cmake -DCMAKE_INSTALL_PREFIX=install -P cmake_install.cmake
        mkdir ../build-iphonesimulator
        cd ../build-iphonesimulator
        cmake -GXcode -DBUILD_SHARED_LIBS=ON -DCMAKE_MACOSX_BUNDLE=ON -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED=NO -DAPPLE_FRAMEWORK=ON -DCMAKE_INSTALL_PREFIX=install -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../platforms/ios/cmake/Toolchains/Toolchain-iPhoneSimulator_Xcode.cmake ../
        xcodebuild -arch x86_64 -arch i386 -sdk iphonesimulator -configuration Release -parallelizeTargets -jobs 4 ONLY_ACTIVE_ARCH=NO IPHONEOS_DEPLOYMENT_TARGET=8.0 -target ALL_BUILD build OTHER_CFLAGS='$(inherited) -Wno-implicit-function-declaration'
        mv ../build-iphoneos/install/ ../
        cd ../install
        mv lib/libopencv_world.dylib lib/opencv2
        mv ../build-iphonesimulator/lib/Release/libopencv_world.dylib lib/opencv2_sim
        lipo -create lib/opencv2 lib/opencv2_sim -output ./opencv2
        echo 'Building dynamic framework...'
        mkdir -p ./framework/opencv2.framework/Headers
        cp ./opencv2 ./framework/opencv2.framework/opencv2
        cp -a ./include/. ./framework/opencv2.framework/Headers/
        cp ../build-iphoneos/ios/Info.plist ./framework/opencv2.framework/Info.plist
        plutil -convert binary1 ./framework/opencv2.framework/Info.plist
        cd ..
        cp -a ./install/framework/opencv2.framework ./opencv2.framework
    CMD
end
