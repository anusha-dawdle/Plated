//
//  FollowRequestsView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI

struct FollowRequestsView: View {
    @EnvironmentObject var dataService: FirebaseDataService
    @State private var processingRequestId: UUID?

    var body: some View {
        Group {
            if dataService.followRequests.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(dataService.followRequests) { request in
                        FollowRequestRow(
                            request: request,
                            isProcessing: processingRequestId == request.id,
                            onAccept: {
                                await acceptRequest(request)
                            },
                            onReject: {
                                await rejectRequest(request)
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Follow Requests")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No requests")
                .font(.title3.weight(.medium))

            Text("You'll see follow requests here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func acceptRequest(_ request: FollowRequest) async {
        processingRequestId = request.id
        do {
            try await dataService.acceptFollowRequest(request)
        } catch {
            print("Error accepting request: \(error)")
        }
        processingRequestId = nil
    }

    private func rejectRequest(_ request: FollowRequest) async {
        processingRequestId = request.id
        do {
            try await dataService.rejectFollowRequest(request)
        } catch {
            print("Error rejecting request: \(error)")
        }
        processingRequestId = nil
    }
}

struct FollowRequestRow: View {
    let request: FollowRequest
    let isProcessing: Bool
    let onAccept: () async -> Void
    let onReject: () async -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            if let profileImageUrl = request.fromUserProfileImageUrl {
                AsyncImage(url: URL(string: profileImageUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(request.fromUserName)
                    .font(.headline)

                Text("@\(request.fromUserUsername)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isProcessing {
                ProgressView()
            } else {
                HStack(spacing: 8) {
                    Button {
                        Task {
                            await onReject()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.red)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }

                    Button {
                        Task {
                            await onAccept()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        FollowRequestsView()
            .environmentObject(FirebaseDataService())
    }
}
