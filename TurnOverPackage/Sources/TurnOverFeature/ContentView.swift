import SwiftUI

// MARK: - Main Content View

public struct ContentView: View {
    @StateObject private var appState = AppState.shared
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                CameraView()
            }
            .tabItem {
                Image(systemName: "camera.fill")
                Text("Capture")
            }
            .tag(0)
            
            NavigationView {
                InventoryView()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Inventory")
            }
            .tag(1)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(2)
        }
        .accentColor(AppTheme.primary)
        .environmentObject(appState)
    }
}

// MARK: - Camera View

public struct CameraView: View {
    @EnvironmentObject var appState: AppState
    @State private var showImagePicker = false
    @State private var showAnalysis = false
    @State private var selectedImage: UIImage?
    
    // Check if running in simulator
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    public var body: some View {
        VStack(spacing: AppTheme.spacingLG) {
            // Header
            Text("Capture Your Item")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Take 1-10 photos of the item you want to sell or donate")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Simulator Notice
            if isSimulator {
                HStack {
                    Image(systemName: "info.circle.fill")
                    Text("Simulator Mode: Using photo library")
                }
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(8)
            }
            
            // Photo Grid
            if appState.capturedPhotos.isEmpty {
                // Empty state
                VStack(spacing: AppTheme.spacingMD) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    
                    Text("No photos yet")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
                .background(AppTheme.background)
                .cornerRadius(AppTheme.radiusMD)
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.spacingSM) {
                        ForEach(Array(appState.capturedPhotos.enumerated()), id: \.element.id) { index, photo in
                            PhotoThumbnail(photo: photo, index: index)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: AppTheme.spacingMD) {
                Button(action: { showImagePicker = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(appState.capturedPhotos.isEmpty ? "Add Photo" : "Add Another Photo")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(appState.capturedPhotos.count >= 10)
                
                if !appState.capturedPhotos.isEmpty {
                    Button(action: { showAnalysis = true }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Analyze with AI")
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                
                // Mock Data Button (Simulator Only)
                if isSimulator {
                    Button(action: { appState.loadMockData() }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text("Load Test Data")
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.orange)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, AppTheme.spacingLG)
        }
        .navigationTitle("TurnOver")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage,
               let data = image.jpegData(compressionQuality: 0.7) {
                appState.addPhoto(data)
                selectedImage = nil
            }
        }
        .fullScreenCover(isPresented: $showAnalysis) {
            AnalysisView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Photo Thumbnail

struct PhotoThumbnail: View {
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
            Button(action: { appState.removePhoto(at: index) }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
            .padding(4)
            
            // Primary badge
            if photo.isPrimary {
                Text("Primary")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .padding(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .frame(width: 100, height: 100)
    }
}
