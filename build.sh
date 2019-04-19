ver=$(grep -oP 'app.versionName=(.*)' ./android/version.properties)
array=(${ver//=/ })

mkdir ./build/apk
mkdir ./build/apk/${array[1]}

flutter build apk --target-platform android-arm64
cp ./build/app/outputs/apk/release/app-release.apk ./build/apk/${array[1]}/choolo-arm64.apk

flutter build apk --target-platform android-arm
cp ./build/app/outputs/apk/release/app-release.apk ./build/apk/${array[1]}/choolo-arm.apk