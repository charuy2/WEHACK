import pymongo
import easyocr
import re
import sys

def extract_allergens(image_path):
    try:
        # Connect to MongoDB with corrected credentials
        client = pymongo.MongoClient("mongodb+srv://pxv5408:HJyaXCdwlMcrMIRa@cluster0.jp3cw4q.mongodb.net/")
        db = client["Ingredients"]
        collection = db["Allergens"]
        
        # Initialize EasyOCR reader
        reader = easyocr.Reader(['en'])
        
        # Perform OCR on images
        results = reader.readtext(image_path)
        
        # Define a document ID
        document_id = 1
        
        # Concatenate extracted text into one string
        extracted_text = ""
        for result in results:
            extracted_text += result[1] + " "  # Add space between words
            
        # Remove unwanted characters
        cleaned_text = re.sub(r'[^a-zA-Z,\s]', '', extracted_text)
        
        # Insert cleaned text into MongoDB
        collection.update_one(
            {"_id": document_id},
            {"$set": {"cleaned_text": cleaned_text}},
            upsert=True
        )
    except pymongo.errors.ServerSelectionTimeoutError as err:
        print("Error connecting to MongoDB:", err)
    except Exception as e:
        print("An error occurred:", e)

if __name__ == "__main__":
    # The first command-line argument will be the path to the image
    image_path = sys.argv[1]
    extract_allergens(image_path)
