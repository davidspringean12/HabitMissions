//
//  LoginView.swift
//  HabitMissions
//
//  Created by David Springean on 18.05.25.
//


import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp = false
    @State private var errorMessage: String = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [AppColors.spaceBlue, AppColors.spaceDark]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // App title
                VStack(spacing: 10) {
                    Text("HabitMissions")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Build Habits, Explore Space")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.starYellow)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Login form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    Button(action: performAction) {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.cosmicPurple)
                            .cornerRadius(8)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                    
                    Button(action: {
                        isSignUp.toggle()
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .foregroundColor(AppColors.starYellow)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                Spacer()
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func performAction() {
        if isSignUp {
            // Create user
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                handleAuthResult(result, error)
            }
        } else {
            // Sign in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                handleAuthResult(result, error)
            }
        }
    }
    
    private func handleAuthResult(_ result: AuthDataResult?, _ error: Error?) {
        if let error = error {
            errorMessage = error.localizedDescription
            showError = true
        }
        // Successful auth will automatically update the app's state via the listener
    }
}