//
//  CreatePostView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataService: FirebaseDataService
    @EnvironmentObject var authService: AuthenticationService

    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var caption = ""
    @State private var selectedTag: MealTag = .breakfast
    @State private var showingSourceChoice = false
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var isUploading = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Image selection
                    if let image = selectedImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Button {
                                selectedImage = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .background(Circle().fill(.black.opacity(0.5)))
                            }
                            .padding(8)
                        }
                    } else {
                        Button {
                            showingSourceChoice = true
                        } label: {
                            HStack {
                                Image(systemName: "camera")
                                Text("Add Photo")
                            }
                        }
                    }
                }

                Section("Details") {
                    TextField("Caption", text: $caption, axis: .vertical)
                        .lineLimit(1...5)

                    Picker("Meal type", selection: $selectedTag) {
                        ForEach(MealTag.allCases, id: \.self) { tag in
                            HStack {
                                Image(systemName: tag.icon)
                                Text(tag.rawValue)
                            }
                            .tag(tag)
                        }
                    }
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Button("Post") {
                            createPost()
                        }
                        .disabled(selectedImage == nil || caption.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .confirmationDialog("Choose photo source", isPresented: $showingSourceChoice) {
                Button("Camera") {
                    showingCamera = true
                }
                Button("Photo Library") {
                    showingPhotoPicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                }
            }
        }
    }

    private func createPost() {
        guard let image = selectedImage,
              let currentUser = authService.currentUser else { return }

        isUploading = true

        Task {
            do {
                let post = SocialPost(
                    authorId: currentUser.id.uuidString,
                    authorName: currentUser.name,
                    authorProfileImageUrl: currentUser.profileImageUrl,
                    imageUrl: nil, // Will be set during upload
                    caption: caption,
                    mealTag: selectedTag
                )

                try await dataService.addPost(post, image: image)

                isUploading = false
                dismiss()
            } catch {
                isUploading = false
                print("Error creating post: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    CreatePostView()
        .environmentObject(FirebaseDataService())
        .environmentObject(AuthenticationService())
}
