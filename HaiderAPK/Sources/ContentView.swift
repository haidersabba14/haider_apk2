import SwiftUI
import UniformTypeIdentifiers

private enum Palette {
    static let background = Color(red: 0.035, green: 0.04, blue: 0.085)
    static let surface = Color(red: 0.095, green: 0.105, blue: 0.17)
    static let cyan = Color(red: 0.20, green: 0.80, blue: 1.0)
    static let purple = Color(red: 0.65, green: 0.36, blue: 1.0)
    static let gradient = LinearGradient(
        colors: [cyan, purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct ContentView: View {
    @StateObject private var library = APKLibrary()
    @State private var showingImporter = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Palette.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        importCard
                        sectionHeader

                        if library.packages.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(library.packages) { package in
                                    NavigationLink {
                                        APKDetailView(package: package, library: library)
                                    } label: {
                                        packageRow(package)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        safetyNote
                    }
                    .padding(20)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [UTType(filenameExtension: "apk") ?? .data, .data],
                allowsMultipleSelection: true
            ) { result in
                do {
                    let urls = try result.get()
                    try library.importFiles(urls)
                } catch {
                    alertMessage = error.localizedDescription
                }
            }
            .alert(
                "معلومة",
                isPresented: Binding(
                    get: { alertMessage != nil },
                    set: { if !$0 { alertMessage = nil } }
                )
            ) {
                Button("حسنًا", role: .cancel) { alertMessage = nil }
            } message: {
                Text(alertMessage ?? "")
            }
        }
        .tint(Palette.cyan)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundStyle(Palette.gradient)
                    .frame(width: 52, height: 52)
                    .background(Palette.surface, in: RoundedRectangle(cornerRadius: 15))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Haider APK")
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("EMULATOR LAB")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(2)
                        .foregroundStyle(Palette.cyan)
                }
                Spacer()
                Text("MVP 1.0")
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Palette.surface, in: Capsule())
            }

            Text("مكتبتك لتطبيقات Android")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("استورد ملفات APK وافحص محتوياتها على الآيفون. تشغيل تطبيقات أندرويد غير متوفر في هذه النسخة.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var importCard: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                Image(systemName: "square.and.arrow.down.on.square.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Palette.gradient)
                Spacer()
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(Palette.cyan)
                Text("محلي وآمن")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.8))
            }

            Text("أضف ملف APK")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("اختر ملف APK من تطبيق الملفات. سيُحفظ داخل مكتبتك دون رفعه إلى أي سيرفر.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.68))

            Button {
                showingImporter = true
            } label: {
                Label("استيراد APK", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .background(Palette.gradient, in: RoundedRectangle(cornerRadius: 15))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 23))
        .overlay(
            RoundedRectangle(cornerRadius: 23)
                .stroke(Palette.cyan.opacity(0.18), lineWidth: 1)
        )
    }

    private var sectionHeader: some View {
        HStack {
            Text("ملفات APK")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Spacer()
            Text("\(library.packages.count) ملف")
                .font(.caption.bold())
                .foregroundStyle(Palette.cyan)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 34))
                .foregroundStyle(.white.opacity(0.3))
            Text("ما أضفت ملفات للحين")
                .font(.headline)
                .foregroundStyle(.white)
            Text("اضغط استيراد APK عشان تبدأ")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 45)
        .background(Palette.surface.opacity(0.65), in: RoundedRectangle(cornerRadius: 20))
    }

    private func packageRow(_ package: APKRecord) -> some View {
        HStack(spacing: 13) {
            Image(systemName: "shippingbox.fill")
                .font(.title3)
                .foregroundStyle(Palette.gradient)
                .frame(width: 48, height: 48)
                .background(Palette.background, in: RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 5) {
                Text(package.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(package.formattedSize) • \(package.entryCount) عنصر")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
            Image(systemName: "chevron.left")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(14)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 17))
    }

    private var safetyNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Palette.cyan)
            Text("هذه أداة حقيقية لاستيراد وفحص APK، وليست محاكي Android. لا يمكن تشغيل كود APK على iOS بدون دمج محرك أندرويد متوافق.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.top, 4)
    }
}

private struct APKDetailView: View {
    let package: APKRecord
    @ObservedObject var library: APKLibrary
    @Environment(\.dismiss) private var dismiss
    @State private var showingEngineInfo = false

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Label(package.name, systemImage: "app.badge")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    infoCard("حجم الملف", package.formattedSize, icon: "externaldrive")
                    infoCard("ملفات داخل الحزمة", "\(package.entryCount)", icon: "doc.zipper")
                    infoCard(
                        "معماريات Android",
                        package.nativeABIs.isEmpty ? "لا توجد مكتبات أصلية" : package.nativeABIs.joined(separator: "، "),
                        icon: "cpu"
                    )
                    VStack(alignment: .leading, spacing: 10) {
                        Text("تشغيل التطبيق")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("غير متاح حاليًا: لا يوجد محرك Android مضمن في هذا الإصدار.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.65))
                        Button("ليش ما يشتغل؟") {
                            showingEngineInfo = true
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(Palette.cyan)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Palette.surface, in: RoundedRectangle(cornerRadius: 18))

                    Text("عينة من محتويات APK")
                        .font(.headline)
                        .foregroundStyle(.white)
                    ForEach(package.filePreview, id: \.self) { path in
                        Text(path)
                            .font(.caption.monospaced())
                            .foregroundStyle(.white.opacity(0.68))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    ShareLink(item: library.url(for: package)) {
                        Label("مشاركة ملف APK", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(role: .destructive) {
                        library.delete(package)
                        dismiss()
                    } label: {
                        Label("حذف من المكتبة", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(20)
            }
        }
        .navigationTitle("تفاصيل APK")
        .navigationBarTitleDisplayMode(.inline)
        .alert("محرك Android غير موجود", isPresented: $showingEngineInfo) {
            Button("فهمت", role: .cancel) { }
        } message: {
            Text("الآيفون لا يشغّل ملفات APK مباشرة. يحتاج المشروع لمحاكاة Android فعلية، وقد تمنع قيود iOS تشغيل بعض البرامج حتى مع وجود محاكي.")
        }
    }

    private func infoCard(_ title: String, _ value: String, icon: String) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .foregroundStyle(Palette.cyan)
                .frame(width: 28)
            Text(title)
                .foregroundStyle(.white.opacity(0.68))
            Spacer(minLength: 8)
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}
