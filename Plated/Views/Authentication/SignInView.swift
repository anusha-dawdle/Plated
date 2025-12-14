//
//  SignInView.swift
//  Plated
//
//  Created by Claude on 12/14/2025.
//

import SwiftUI
import GoogleSignInSwift

struct SignInView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var isLoading = false
    @State private var showError = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // App logo and title
                VStack(spacing: 16) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange)

                    Text("Plated")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.primary)

                    Text("Plan meals, share moments")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Sign in button
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    } else {
                        // Google Sign-In Button
                        GoogleSignInButton(action: signIn)
                            .frame(height: 50)
                            .padding(.horizontal, 40)
                    }

                    if let error = authService.authError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK") {
                authService.authError = nil
            }
        } message: {
            if let error = authService.authError {
                Text(error)
            }
        }
    }

    private func signIn() {
        isLoading = true
        authService.authError = nil

        Task {
            do {
                try await authService.signInWithGoogle()
            } catch {
                authService.authError = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthenticationService())
}
