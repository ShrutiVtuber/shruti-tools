allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ─────────────────────────────────────────────────────────────────────────────
// The two blocks below are PORTED FROM astropractise, which worked them out
// against this same sweph version. They are here verbatim rather than
// rediscovered: the first cost a build, and the second is a release blocker
// that produces no build error at all.
//
// Before changing either, read the comments — both record why the obvious
// simpler version does not work.
// ─────────────────────────────────────────────────────────────────────────────

// Raise stale plugins' compileSdk to match the app's.
//
// The `sweph` plugin (3.2.1+2.10.3) declares compileSdk 31, but its transitive
// AndroidX dependencies — fragment 1.7.1, window 1.2.0 and others — now require
// consumers to compile against 34+. Without this the build fails in
// :sweph:checkDebugAarMetadata with twenty such conflicts.
//
// compileSdk only controls which APIs are available at compile time. It does
// NOT change runtime behaviour (that is targetSdk) or device compatibility
// (that is minSdk), so lifting it for a dependency is safe — this is the
// standard remedy for a plugin that has fallen behind its own dependencies.
//
// ⚠ MUST be registered before the evaluationDependsOn(":app") block below.
// That block evaluates projects eagerly, and Gradle refuses afterEvaluate on an
// already-evaluated project ("Cannot run Project.afterEvaluate(Action) when the
// project is already evaluated").
//
// Reflection rather than a typed cast because the Android extension type
// differs between application and library plugins, and AGP has moved these
// interfaces between packages across major versions. A missing method means
// "not an Android project", which is handled rather than fatal.
//
// Ported verbatim from the sibling project (theourgia), where it was worked out
// against this exact plugin version. Remove once sweph ships a build targeting
// a current SDK. Scoped away from :app, whose compileSdk stays pinned to
// flutter.compileSdkVersion.
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            project.extensions.findByName("android")?.let { android ->
                try {
                    val current = android.javaClass
                        .getMethod("getCompileSdk")
                        .invoke(android) as Int?
                    if (current == null || current < 36) {
                        android.javaClass
                            .getMethod("setCompileSdk", Integer::class.java)
                            .invoke(android, 36)
                        logger.lifecycle(
                            "Raised ${project.name} compileSdk ${current ?: "unset"} -> 36",
                        )
                    }
                } catch (_: NoSuchMethodException) {
                    // Not an Android extension exposing compileSdk; leave it be.
                }
            }
        }
    }
}

// ⚠ 16 KB PAGE-SIZE ALIGNMENT — a Play Store release blocker.
//
// Android requires native libraries to tolerate a 16 KB memory page. Devices
// still run 4 KB pages today, so nothing is broken in development — but Google
// Play gates releases on it, and the failure appears only as a system dialog on
// a real device, never in a build log.
//
// Measured, rather than assumed: of the six native libraries in a release APK,
// FIVE are already fine (libflutter and libapp at 64 KB; libdartjni,
// libsqlite3 and libdatastore_shared_counter at 16 KB). Only `libsweph.so`
// still has 4 KB LOAD segments.
//
// It is built from source by CMake at app-build time rather than shipped
// prebuilt, which is what makes this fixable here at all: passing the linker
// its max-page-size is enough, and no fork or upstream patch is needed.
//
// ⚠ Verify with tool/check_native_alignment.py after changing anything here.
// This flag is silent when it fails — the build still succeeds and the library
// is still misaligned, so "the build passed" proves nothing.
//
// Remove once sweph ships a build that aligns for 16 KB itself.
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            project.extensions.findByName("android")?.let { android ->
                try {
                    val defaultConfig = android.javaClass
                        .getMethod("getDefaultConfig").invoke(android)
                    val nativeBuild = defaultConfig.javaClass
                        .getMethod("getExternalNativeBuild").invoke(defaultConfig)
                    val cmake = nativeBuild.javaClass
                        .getMethod("getCmake").invoke(nativeBuild)
                    @Suppress("UNCHECKED_CAST")
                    val args = cmake.javaClass
                        .getMethod("getArguments").invoke(cmake) as MutableList<String>
                    val flag = "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-z,max-page-size=16384"
                    if (args.none { it.startsWith("-DCMAKE_SHARED_LINKER_FLAGS") }) {
                        args.add(flag)
                        logger.lifecycle("16 KB alignment: added linker flag to ${project.name}")
                    }
                } catch (e: Exception) {
                    // Not a project with a CMake native build, or AGP moved the
                    // accessor. Not fatal — but it does mean the flag was NOT
                    // applied, so say so rather than failing quietly.
                    logger.info("16 KB alignment: skipped ${project.name} (${e.javaClass.simpleName})")
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
