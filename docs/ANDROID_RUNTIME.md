# Android runtime: honest engineering status

The current iOS application **does not execute APK files**.

An Android APK contains Android application bytecode, resources, and sometimes native
Android libraries. Importing or unpacking the ZIP cannot make that bytecode run
under the iOS runtime. Apple's SwiftUI and ZIPFoundation only provide the user
interface and archive inspection.

A genuine offline APK runner would need, at minimum:

1. A usable Android environment (kernel/userspace/Android runtime, or equivalent).
2. Emulation/virtualization compatible with iOS sandbox, entitlements, and hardware.
3. Touch, graphics, audio, filesystem, and network bridges.
4. An Android installer, activity manager and lifecycle handling.
5. Device-specific performance and entitlement testing.
6. Clear disclosure that not every APK can work, including services requiring
   Google Play, DRM, external architecture-specific native libraries, and JIT.

QEMU or UTM-style system emulation might inform future research, but simply
adding QEMU as a dependency will NOT enable one-click APK execution.

## Implemented in MVP

- Secure local APK import (Files provider security-scoped URLs).
- ZIP structure validation: AndroidManifest.xml and classes.dex.
- Archive entry preview and architecture (ABI) discovery.
- Local persistent APK library, share, and delete.
- Dark SwiftUI interface.
- GitHub Actions Xcode build producing an **unsigned** IPA.

## Not implemented

- Android guest VM, Android installation, and actual APK execution.
- Play Services or DRM integration.
- Installation-ready signed IPA. The unsigned build must be signed with an
  appropriate developer certificate/provisioning profile before iOS installation.
