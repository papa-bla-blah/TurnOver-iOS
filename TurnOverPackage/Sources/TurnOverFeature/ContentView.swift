import SwiftUI
import AVFoundation

// MARK: - Main Content View (HIG Compliant)

@available(iOS 15.0, *)
public struct ContentView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var preferences = UserPreferences.shared
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CaptureView()
            }
            .tabItem {
                Label("Capture", systemImage: "camera.fill")
            }
            .tag(0)
            
            NavigationStack {
                InventoryView()
            }
            .tabItem {
                Label("Inventory", systemImage: "list.bullet")
            }
            .tag(1)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
        .tint(AppTheme.primary)
        .environmentObject(appState)
        .environmentObject(preferences)
    }
}

// MARK: - Capture View (Renamed from CameraView for clarity)

@available(iOS 15.0, *)
public struct CaptureView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var preferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    
    @State private var showImagePicker = false
    @State private var showLevelLockCamera = false
    @State private var showAnalysis = false
    @State private var selectedImage: UIImage?
    @State private var showCameraChoice = false
    
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    private var hasCameraAccess: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLG) {
                // Header
                VStack(spacing: AppTheme.spacingSM) {
                    Text("Capture Your Item")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("Take 1-10 photos for AI analysis")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .accessibilityElement(children: .combine)
                .padding(.top)
                
                // Simulator Notice
                if isSimulator {
                    SimulatorNoticeView()
                }
                
                // Photo Grid
                PhotoGridSection()
                
                // Action Buttons
                ActionButtonsSection(
                    showCameraChoice: $showCameraChoice,
                    showAnalysis: $showAnalysis,
                    isSimulator: isSimulator
                )
            }
            .padding(.horizontal)
        }
        .navigationTitle("TurnOver")
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog("Add Photo", isPresented: $showCameraChoice) {
            if !isSimulator {
                Button("Level Lock Camera") {
                    HapticManager.selection()
                    showLevelLockCamera = true
                }
                
                Button("Standard Camera") {
                    HapticManager.selection()
                    showImagePicker = true
                }
            }
            
            Button("Photo Library") {
                HapticManager.selection()
                showImagePicker = true
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose photo source")
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .fullScreenCover(isPresented: $showLevelLockCamera) {
            LevelLockCameraView(capturedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            handleNewImage(newImage)
        }
        .fullScreenCover(isPresented: $showAnalysis) {
            AnalysisView()
                .environmentObject(appState)
                .environmentObject(preferences)
        }
    }
    
    private func handleNewImage(_ image: UIImage?) {
        guard let image = image else { return }
        let quality = preferences.compressionQuality
        if let data = image.jpegData(compressionQuality: quality) {
            HapticManager.notification(.success)
            appState.addPhoto(data)
            selectedImage = nil
        }
    }
}

// MARK: - Simulator Notice

struct SimulatorNoticeView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.orange)
            Text("Simulator: Using photo library")
                .font(.footnote)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.12))
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Running in simulator mode, using photo library")
    }
}

// MARK: - Photo Grid Section

@available(iOS 15.0, *)
struct PhotoGridSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.capturedPhotos.isEmpty {
                EmptyPhotoState()
            } else {
                PhotoScrollView()
            }
        }
    }
}

struct EmptyPhotoState: View {
    var body: some View {
        VStack(spacing: AppTheme.spacingMD) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.textTertiary)
            
            Text("No photos yet")
                .font(.headline)
                .foregroundColor(AppTheme.textSecondary)
            
            Text("Add photos to get started")
                .font(.subheadline)
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(AppTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No photos captured yet")
    }
}

@available(iOS 15.0, *)
struct PhotoScrollView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            HStack {
                Text("Photos")
                    .font(.headline)
                Spacer()
                Text("\(appState.capturedPhotos.count)/10")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.spacingSM) {
                    ForEach(Array(appState.capturedPhotos.enumerated()), id: \.element.id) { index, photo in
                        PhotoThumbnailView(photo: photo, index: index)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusMD))
    }
}

@available(iOS 15.0, *)
struct PhotoThumbnailView: View {
    let photo: Photo
    let index: Int
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let data = photo.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM))
            }
            
            // Delete button
            Button {
                HapticManager.impact(.light)
                withAnimation(.easeOut(duration: 0.2)) {
                    appState.removePhoto(at: index)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
            }
            .accessibleTapTarget()
            .accessibilityLabel("Remove photo \(index + 1)")
            .padding(4)
            
            // Primary badge
            if photo.isPrimary {
                Text("Primary")
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .frame(width: 100, height: 100)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Photo \(index + 1)\(photo.isPrimary ? ", primary" : "")")
        .contextMenu {
            if !photo.isPrimary {
                Button {
                    appState.setPrimaryPhoto(at: index)
                } label: {
                    Label("Set as Primary", systemImage: "star")
                }
            }
            
            Button(role: .destructive) {
                appState.removePhoto(at: index)
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }
}

// MARK: - Action Buttons Section

@available(iOS 15.0, *)
struct ActionButtonsSection: View {
    @EnvironmentObject var appState: AppState
    @Binding var showCameraChoice: Bool
    @Binding var showAnalysis: Bool
    let isSimulator: Bool
    
    var body: some View {
        VStack(spacing: AppTheme.spacingMD) {
            // Add Photo Button
            Button {
                HapticManager.impact(.medium)
                showCameraChoice = true
            } label: {
                Label(
                    appState.capturedPhotos.isEmpty ? "Add Photo" : "Add Another",
                    systemImage: "plus.circle.fill"
                )
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(appState.capturedPhotos.count >= 10)
            .accessibilityHint(appState.capturedPhotos.count >= 10 ? "Maximum photos reached" : "")
            
            // Analyze Button
            if !appState.capturedPhotos.isEmpty {
                Button {
                    HapticManager.impact(.medium)
                    showAnalysis = true
                } label: {
                    Label("Analyze with AI", systemImage: "sparkles")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            // Simulator test data
            if isSimulator {
                Button {
                    appState.loadMockData()
                    HapticManager.notification(.success)
                } label: {
                    Label("Load Test Data", systemImage: "doc.badge.plus")
                        .font(.footnote)
                }
                .foregroundColor(.orange)
                .padding(.top, 8)
            }
        }
        .padding(.vertical)
    }
}
