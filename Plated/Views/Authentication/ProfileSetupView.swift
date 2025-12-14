//
//  ProfileSetupView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI
import PhotosUI

struct ProfileSetupView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) var dismiss

    @State private var displayName: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isUploading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Complete Your Profile")
                            .font(.largeTitle.bold())

                        Text("Add a profile picture and display name")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)

                    // Profile Picture
                    VStack(spacing: 16) {
                        if let profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else if let profileImageUrl = authService.currentUser?.profileImageUrl {
                            AsyncImage(url: URL(string: profileImageUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundStyle(.secondary)
                                .frame(width: 120, height: 120)
                        }

                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            Label("Change Photo", systemImage: "camera")
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.vertical)

                    // Display Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        TextField("Enter your name", text: $displayName)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Continue Button
                    Button {
                        completeSetup()
                    } label: {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Continue")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(displayName.isEmpty ? Color.gray : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .disabled(displayName.isEmpty || isUploading)

                    // Skip Button
                    Button("Skip for now") {
                        skipSetup()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Pre-fill with Google name
            displayName = authService.currentUser?.name ?? ""
        }
        .onChange(of: selectedImage) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = uiImage
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    private func completeSetup() {
        isUploading = true

        Task {
            do {
                // Upload profile image if one was selected
                var imageUrl: String? = authService.currentUser?.profileImageUrl

                if let profileImage,
                   let imageData = profileImage.jpegData(compressionQuality: 0.7),
                   let userId = authService.currentUser?.id.uuidString {
                    imageUrl = try await StorageService.shared.uploadProfileImage(imageData, userId: userId)
                }

                // Update user profile
                try await authService.updateProfile(name: displayName, profileImageUrl: imageUrl)

                isUploading = false
                dismiss()
            } catch {
                isUploading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func skipSetup() {
        dismiss()
    }
}

#Preview {
    ProfileSetupView()
        .environmentObject(AuthenticationService())
}
