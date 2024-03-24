import pymongo


# Connect to MongoDB client
allergy_names = ["dairy"]
product_ingredients = "salt,milk,water"
client = pymongo.MongoClient("mongodb+srv://pxv5408:HJyaXCdwlMcrMIRa@cluster0.jp3cw4q.mongodb.net/")
allergies_db = client["allergies_list"]


def check_allergies(allergy_names, product_ingredients):
    allergic_products = []


    # Query allergies_list database for allergenic foods
    allergies_collection = allergies_db["allergy"]
    for allergy_name in allergy_names:
        allergy = allergies_collection.find_one({"name": allergy_name})
        if allergy:
            allergenic_foods = allergy["foods"]
            # Split the product ingredients string into individual ingredients
            ingredients_list = product_ingredients.split(',')
            # Check if any allergenic food is present in the product ingredients
            for food in allergenic_foods:
                if food in ingredients_list:
                    allergic_products.append(allergy_name)
                    break  # No need to continue checking for this allergy


    return allergic_products


if __name__ == "__main__":
    # Predefined array of allergy names
    allergy_names = ["dairy", "gluten"]


    # Example product ingredients string from image processing
    product_ingredients = "salt,milk,water"


    # Convert product ingredients string to lowercase for case-insensitive comparison
    product_ingredients_lower = product_ingredients.lower()


    allergic_products = check_allergies(allergy_names, product_ingredients_lower)
    print("Allergic products:", allergic_products)

