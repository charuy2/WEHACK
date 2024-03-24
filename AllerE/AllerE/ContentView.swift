import SwiftUI
import PythonKit
import UIKit

func initializePython() {
    #if DEBUG
    let pythonLibraryPath = "/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9"
    #else
    let pythonLibraryPath = "/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/3.9"
    #endif
    
    // Set the PYTHON_LIBRARY environment variable
    setenv("PYTHON_LIBRARY", pythonLibraryPath, 1)
    
    PythonLibrary.useLibrary(at: pythonLibraryPath)
}

// Define the ImagePicker struct here
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

// Global variable to store selected image
class ImageSelection: ObservableObject {
    @Published var selectedImage: UIImage?
    
    func sendImageToPython(allergies_values: [Bool], path: String) {
        let python = Python.shared
        python.run("""
            import sys
            sys.path.append('.')
            import get_allergens
            import pytesseract
            
            pytesseract.pytesseract.tesseract_cmd = '/usr/local/bin/tesseract' # Path to your Tesseract executable
            
            get_allergens.check_allergies(\(Python.list(allergies_values)), "\(path)")
        """)
    }
}

struct ContentView: View {
    init() {
        initializePython() // Call the function to initialize Python library path
    }
    @State private var xOffset: CGFloat = 0

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to AllerEase")
                    .font(.custom("Snell Roundhand", size: 54).bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .offset(x: xOffset, y: 0) // Apply the offset
                    .background(Image("background"))
                
                NavigationLink(destination: LoginView()) {
                    Text("Go to Login")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)
                    Image("fairy")
                        .resizable()
                        .frame(width: 50, height: 50) // Set fixed size
                        .aspectRatio(contentMode: .fit)
                        .offset(x: -150, y: 0) // Adjust the y offset to position it closer to the bottom
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 2).repeatForever()) { // Apply animation
                                xOffset = 200
                            }
                        }
                        .padding(.leading, 20) // Add padding to move the fairy image right
                        .padding(.bottom, 20) // Add padding to move the fairy image up
                }
            }
            .padding()
            .navigationTitle("Home")
            .navigationBarItems(trailing: EmptyView())
            .environmentObject(ImageSelection())
        }
    }
}

// Global variable to store selected allergens
class AllergenSelection: ObservableObject {
    @Published var selectedAllergens: [String] = []
}

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @StateObject private var imageSelection = ImageSelection()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("")
                    .foregroundColor(.black)
                    .background(Image("background"))
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.green)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.green)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    // Perform login authentication
                    isLoggedIn = authenticate(username: username, password: password)
                }) {
                    Text("Login")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()
                
                if isLoggedIn {
                    NavigationLink(destination: AllergenSelectionView(imageSelection: imageSelection)) {
                        Text("Proceed to Allergen Selection")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                } else {
                    Text("Invalid username or password.")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .navigationBarTitle("Sign In", displayMode: .inline)
            .foregroundColor(.black)
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

struct AllergenSelectionView: View {
    @EnvironmentObject var allergenSelection: AllergenSelection
    @ObservedObject var imageSelection: ImageSelection
    
    let allergens = ["Gluten", "Dairy", "Shellfish", "Peanuts", "Tree Nuts", "Eggs", "Soy", "Fish", "Wheat", "Corn", "Sesame", "Sulfites", "Lupin", "Mustard", "Celery"]
    
    @State private var allergiesValues = Array(repeating: false, count: 15)
    @State private var isImagePickerPresented: Bool = false
    
    var body: some View {
        VStack {
            List {
                ForEach(0..<allergens.count) { i in
                    Toggle(allergens[i], isOn: $allergiesValues[i])
                }
            }
            
            NavigationLink(destination: ImageUploadView(imageSelection: imageSelection, allergiesValues: allergiesValues)) {
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
            if let image = imageSelection.selectedImage,
               let data = image.jpegData(compressionQuality: 1.0),
               let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("image.jpg").path {
                do {
                    try data.write(to: URL(fileURLWithPath: path))
                    imageSelection.sendImageToPython(allergies_values: allergiesValues, path: path)
                } catch {
                    print("Error writing image:", error)
                }
            }
        }
    }
}


struct ImageUploadView: View {
    @ObservedObject var imageSelection: ImageSelection
    var allergiesValues: [Bool]
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
            
            Button(action: {
                // Save the image and call main.py to process the text
                if let image = imageSelection.selectedImage,
                   let data = image.jpegData(compressionQuality: 1.0),
                   let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("image.jpg").path {
                    do {
                        try data.write(to: URL(fileURLWithPath: path))
                        // Call main.py to process the text in the image
                        callMainPythonScript(imagePath: path)
                    } catch {
                        print("Error writing image:", error)
                    }
                }
            }) {
                Text("Process Image")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $imageSelection.selectedImage)
        }
        .navigationTitle("Image Upload")
    }
    
    func callMainPythonScript(imagePath: String) {
        let python = Python.shared
        python.run("""
            import sys
            sys.path.append('.')
            import main

            # Call the extract_allergens function in main.py with the image path
            main.extract_allergens('\(imagePath)')
        """)
    }
}
