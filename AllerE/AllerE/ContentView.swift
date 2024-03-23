//
//  ContentView.swift
//  AllerE
//
//  Created by Pragnasri Vellanki on 23/3/2024.
//
import SwiftUI
import UIKit

class ImageSelection: ObservableObject {
    @Published var selectedImage: UIImage?
}
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to My App")
                    .font(.title)
                
                NavigationLink(destination: LoginView()) {
                    Text("Go to Login")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Home")
            .navigationBarItems(trailing: EmptyView())
            .environmentObject(ImageSelection())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Username", text: $username)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    // Perform login authentication
                    isLoggedIn = authenticate(username: username, password: password)
                }) {
                    Text("Login")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                if isLoggedIn {
                    NavigationLink(destination: ImageUploadView()) {
                        Text("Go to Image Upload")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                } else {
                    Text("Invalid username or password.")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationBarTitle("Sign Out", displayMode: .inline)
                        .onAppear {
                            // Reset the fields when the view appears
                            username = ""
                            password = ""
                            isLoggedIn = false
                        }
        }
    }
    
    // Dummy authentication function
    func authenticate(username: String, password: String) -> Bool {
        // Replace this with your actual authentication logic
        return username == "user" && password == "password"
    }
}

struct ImageUploadView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Text("No image selected")
                    .padding()
            }
            
            Button(action: {
                isImagePickerPresented = true
            }) {
                Text("Select Image")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .navigationTitle("Image Upload")
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
