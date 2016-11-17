#include "../jni.hpp"
#include <mbgl/platform/log.hpp>

#include <jni/jni.hpp>
#include <mbgl/test.hpp>

#pragma clang diagnostic ignored "-Wunused-parameter"

#define MAKE_NATIVE_METHOD(name, sig) jni::MakeNativeMethod<decltype(name), name>( #name, sig )

void runAllTests(JNIEnv *env, jni::jobject* obj) {
    mbgl::Log::Info(mbgl::Event::JNI, "Starting tests");
    mbgl::runTests(0, nullptr);
}

extern "C" JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    //Load the main library jni bindings
    mbgl::Log::Info(mbgl::Event::JNI, "Registering main JNI Methods");
    mbgl::android::registerNatives(vm);

    //Load the test library jni bindings
    mbgl::Log::Info(mbgl::Event::JNI, "Registering test JNI Methods");

    jni::JNIEnv& env = jni::GetEnv(*vm, jni::jni_version_1_6);

    struct Main { static constexpr auto Name() { return "Main"; } };
    jni::RegisterNatives(env, jni::Class<Main>::Find(env), MAKE_NATIVE_METHOD(runAllTests, "()V"));

    return JNI_VERSION_1_6;
}
