import pymongo
import easyocr

# Connect to MongoDB
client = pymongo.MongoClient("mongodb+srv://pxv5408:HJyaXCdwlMcrMIRa@cluster0.jp3cw4q.mongodb.net/")
db = client["Ingredients"]
collection = db["Allergens"]

# Initialize EasyOCR reader
reader = easyocr.Reader(['en'])

# Perform OCR on images
results = reader.readtext('/Users/pragnasrivellanki/Desktop/AllerE/image.jpg')

# Insert extracted text into MongoDB
for result in results:
    text = result[1]
    collection.insert_one({"text": text})

