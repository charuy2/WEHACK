from get_allergens import allergy_names
from get_allergens import allergic_products 

def check_allergies(allergy_names, allergic_products):
    allergic_allergies = [allergy for allergy in allergy_names if allergy in allergic_products]
    if allergic_allergies:
        return f"Allerina has realized that this product contains {', '.join(allergic_allergies)}, so here are a list of alternatives for this product!"
    else:
        return "Allerina didn't detect any allergens in this product. Enjoy!"


if __name__ == "__main__":
    # Predefined array of allergy names
    #allergy_names = ["gluten", "dairy", "nuts", "soy"]


    # Example list of allergic products
    #allergic_products = ["dairy", "peanuts", "wheat"]


    result = check_allergies(allergy_names, allergic_products)
    print(result)

