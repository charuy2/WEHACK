import pymongo


# Connect to MongoDB client
client = pymongo.MongoClient("mongodb+srv://pxv5408:HJyaXCdwlMcrMIRa@cluster0.jp3cw4q.mongodb.net/")
db = client["allergies_list"]
collection = db["allergy"]


# Insert allergy data
allergy_data = [
    {"name": "gluten", "foods": ["wheat", "barley", "rye", "oats", "bread", "pasta", "cereals"]},
    {"name": "dairy", "foods": ["milk", "cheese", "butter", "yogurt", "cream", "ice cream"]},
    {"name": "shellfish", "foods": ["shrimp", "crab", "lobster", "clams", "oysters", "scallops"]},
    {"name": "peanuts", "foods": ["peanut butter", "peanut oil", "peanut sauce", "peanut flour"]},
    {"name": "tree nuts", "foods": ["almonds", "walnuts", "cashews", "hazelnuts", "pistachios"]},
    {"name": "eggs", "foods": ["egg whites", "egg yolks", "mayonnaise", "baked goods"]},
    {"name": "soy", "foods": ["soybeans", "tofu", "soy sauce", "soy milk", "tempeh"]},
    {"name": "fish", "foods": ["salmon", "tuna", "halibut", "cod", "sardines", "anchovies"]},
    {"name": "wheat", "foods": ["bread", "pasta", "cereals", "flour", "breadcrumbs", "crackers"]},
    {"name": "corn", "foods": ["cornmeal", "popcorn", "corn starch", "corn syrup", "corn chips"]},
    {"name": "sesame", "foods": ["sesame seeds", "tahini", "sesame oil", "hummus"]},
    {"name": "sulfites", "foods": ["wine", "dried fruit", "pickles", "canned vegetables"]},
    {"name": "lupin", "foods": ["lupin flour", "lupin seeds", "lupin-based products"]},
    {"name": "mustard", "foods": ["mustard seeds", "mustard powder", "prepared mustard"]},
    {"name": "celery", "foods": ["celery stalks", "celery salt", "celery seed", "celery juice"]}
]


# Insert each document into the collection
for document in allergy_data:
    collection.insert_one(document)


print("Allergy data inserted successfully.")

#except pymongo.errors.ServerSelectionTimeoutError as err:
#    print("Error connecting to MongoDB:", err)
#except Exception as e:
#    print("An error occurred:", e)
