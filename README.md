# Product Requirement Document (PRD): Shop Right

## 1. Executive Summary

**Shop Right** is a mobile shopping and price-comparison application designed to help users build a unified grocery list, search for essential products, compare prices across multiple stores (such as local supermarkets and markets), and discover the lowest total cost for their basket or optimal split-purchase routes.

---


## 2. Technical Stack

| Layer | Technology | Key Details |
| --- | --- | --- |
| **Mobile App** | **Flutter** (Dart) | State management (Riverpod/Provider), B&W minimalist UI theme |
| **Backend API** | **Laravel 13** (PHP) | RESTful API, Sanctum authentication, Eloquent ORM |

---



## 3. Core Features & User Stories

### 3.1 Index Screen (Search & List Builder)

* **Product Search:** Users search for grocery items (e.g., "Breakfast Meal 25kg", "White Sugar 2kg").
* **Quick-Add Essentials:** One-tap pill buttons for high-demand local items.
* **Dynamic Shopping List:** Add/remove items and adjust quantities.
* **Budget Indicator:** Track current target budget vs. estimated total.

### 3.2 Results Screen (Price Comparison Engine)

* **Lowest Price Per Item:** Shows which specific store offers each item in the list at the lowest price.
* **Total Basket by Shop:** Ranks local stores by total cost if bought entirely in one location.
* **Smart Savings Combo:** Calculates an optimal multi-store route (e.g., Buy Item A at Store X, Item B at Store Y) for maximum total savings.

---

## 7. Design Guidelines (Monochrome Aesthetic)

* **Primary Colors:** `#030712` (Gray 950 - Dark Base), `#FFFFFF` (Pure White).
* **Secondary / Card Backgrounds:** `#F9FAFB` (Gray 50), `#F3F4F6` (Gray 100), `#E5E7EB` (Gray 200).
* **Typography:** Bold sans-serif with strong uppercase badge accents.
* **Component Styling:** Floating rounded pill bottom-bar, rounded `2xl`/`3xl` cards, subtle borders, and zero non-monochrome alert colors.
