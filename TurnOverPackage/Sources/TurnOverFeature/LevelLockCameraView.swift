import SwiftUI
import AVFoundation
import CoreMotion

// MARK: - Level Lock Camera View (Optional Feature)

@available(iOS 15.0, *)
public struct LevelLockCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var motionManager = DeviceMotionManager()
    @ObservedObject private var preferences = UserPreferences.shared
    
    @Binding var capturedImage: UIImage?
    
    public init(capturedImage: Binding<UIImage?>) {
        self._capturedImage = capturedImage
    }
    
    private var isLevel: Bool {
        guard preferences.levelLockEnabled else { return true }
        let threshold = preferences.levelLockSensitivity
        return abs(motionManager.pitch) < threshold && abs(motionManager.roll) < threshold
    }
    
    public var body: some View {
        ZStack {
            // Camera Preview
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()
            
            // Level Indicator Overlay (when enabled)
            if preferences.levelLockEnabled {
                LevelIndicatorOverlay(
                    pitch: motionManager.pitch,
                    roll: motionManager.roll,
                    isLevel: isLevel,
                    sensitivity: preferences.levelLockSensitivity
                )
            }
            
            // Controls
            VStack {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                    .accessibilityLabel("Close camera")
                    
                    Spacer()
                    
                    // Level Lock Toggle
                    Button(action: {
                        HapticManager.selection()
                        preferences.levelLockEnabled.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: preferences.levelLockEnabled ? "level.fill" : "level")
                            if preferences.levelLockEnabled {
                                Text("LEVEL")
                                    .font(.caption.bold())
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(preferences.levelLockEnabled ? Color.green.opacity(0.8) : Color.black.opacity(0.5))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                    .accessibilityLabel(preferences.levelLockEnabled ? "Level lock on" : "Level lock off")
                }
                .padding()
                
                Spacer()
                
                // Level Status (when enabled)
                if preferences.levelLockEnabled {
                    Text(isLevel ? "✓ Level - Ready to capture" : "Adjust device to level")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isLevel ? Color.green.opacity(0.8) : Color.orange.opacity(0.8))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .animation(.easeInOut(duration: 0.2), value: isLevel)
                }
                
                // Capture Button
                HStack {
                    Spacer()
                    
                    Button(action: capturePhoto) {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 70, height: 70)
                            Circle()
                                .stroke(lineWidth: 4)
                                .foregroundStyle(.white)
                                .frame(width: 80, height: 80)
                        }
                    }
                    .disabled(preferences.levelLockEnabled && !isLevel)
                    .opacity(preferences.levelLockEnabled && !isLevel ? 0.5 : 1.0)
                    .accessibilityLabel("Take photo")
                    .accessibilityHint(preferences.levelLockEnabled && !isLevel ? "Level device first" : "")
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraManager.startSession()
            if preferences.levelLockEnabled {
                motionManager.startUpdates()
            }
        }
        .onDisappear {
            cameraManager.stopSession()
            motionManager.stopUpdates()
        }
        .onChange(of: preferences.levelLockEnabled) { enabled in
            if enabled {
                motionManager.startUpdates()
            } else {
                motionManager.stopUpdates()
            }
        }
    }
    
    private func capturePhoto() {
        HapticManager.impact(.medium)
        cameraManager.capturePhoto { image in
            capturedImage = image
            HapticManager.notification(.success)
            dismiss()
        }
    }
}

// MARK: - Level Indicator Overlay

struct LevelIndicatorOverlay: View {
    let pitch: Double
    let roll: Double
    let isLevel: Bool
    let sensitivity: Double
    
    var body: some View {
        ZStack {
            // Crosshair
            Circle()
                .stroke(isLevel ? Color.green : Color.white, lineWidth: 2)
                .frame(width: 100, height: 100)
            
            // Bubble indicator
            Circle()
                .fill(isLevel ? Color.green : Color.orange)
                .frame(width: 20, height: 20)
                .offset(
                    x: CGFloat(roll * 10).clamped(to: -40...40),
                    y: CGFloat(pitch * 10).clamped(to: -40...40)
                )
                .animation(.easeOut(duration: 0.1), value: pitch)
                .animation(.easeOut(duration: 0.1), value: roll)
            
            // Center target
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                .frame(width: 30, height: 30)
        }
    }
}

// MARK: - Camera Manager

class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
    }
    
    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        captureCompletion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            captureCompletion?(nil)
            return
        }
        captureCompletion?(image)
    }
}

// MARK: - Device Motion Manager

class DeviceMotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.05
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion else { return }
            self?.pitch = motion.attitude.pitch * 180 / .pi
            self?.roll = motion.attitude.roll * 180 / .pi
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}

// MARK: - Camera Preview UIViewRepresentable

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Comparable Extension

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
