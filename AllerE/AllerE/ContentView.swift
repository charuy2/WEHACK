import SwiftUI
import PythonKit

// Global variable to store selected image
class ImageSelection: ObservableObject {
    @Published var selectedImage: UIImage?
    
    func sendImageToPython() {
        if let image = selectedImage,
           let data = image.jpegData(compressionQuality: 1.0),
           let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("image.jpg") {
            do {
                try data.write(to: path)
                let python = Python.shared
                python.run("""
                    import sys
                    sys.path.append('.')
                    import main
                    main.extract_allergens('\(path.path)')
                """)
            } catch {
                print("Error writing image:", error)
            }
        }
    }
}

// Global variable to store selected allergens
class AllergenSelection: ObservableObject {
    @Published var selectedAllergens: [String] = []
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
            .environmentObject(AllergenSelection())
        }
    }
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var imageSelection = ImageSelection()
    
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
                    NavigationLink(destination: AllergenSelectionView()) {
                        Text("Proceed to Allergen Selection")
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
        .environmentObject(imageSelection)
    }
    
    // Dummy authentication function
    func authenticate(username: String, password: String) -> Bool {
        // Replace this with your actual authentication logic
        return username == "user" && password == "password"
    }
}

struct AllergenSelectionView: View {
    @EnvironmentObject var allergenSelection: AllergenSelection
    @EnvironmentObject var imageSelection: ImageSelection
    @State private var isImagePickerPresented: Bool = false
    
    let allergens = ["Gluten", "Dairy", "Shellfish", "Peanuts", "Tree Nuts", "Eggs", "Soy", "Fish", "Wheat", "Corn", "Sesame", "Sulfites", "Lupin", "Mustard", "Celery"]
    
    @State var allergies_values = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    var body: some View {
        VStack {
            List {
                ForEach(0..<allergens.count) { i in
                    Toggle(allergens[i], isOn: $allergies_values[i])
                }
            }
            
            NavigationLink(destination: ImageUploadView()) {
                Text("Proceed to Image Upload")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Allergen Selection")
        .onAppear {
            // Send image to Python script when view appears
            imageSelection.sendImageToPython()
        }
    }
}

struct ImageUploadView: View {
    @EnvironmentObject var imageSelection: ImageSelection
    @State private var isImagePickerPresented: Bool = false
    
    var body: some View {
        VStack {
            if let image = imageSelection.selectedImage {
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
            ImagePicker(selectedImage: $imageSelection.selectedImage)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ImageSelection())
            .environmentObject(AllergenSelection()) // Provide environment object for AllergenSelection
    }
}

