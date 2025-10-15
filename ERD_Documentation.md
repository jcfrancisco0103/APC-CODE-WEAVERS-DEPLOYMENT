# Entity Relationship Diagram (ERD) Documentation
## E-Commerce System - Code Weavers Inventory System

---

## **ENTITIES AND ATTRIBUTES**

### **1. MANAGE ACCOUNTS**

#### **User** (Django built-in)
- **user_id** (PK)
- username
- email
- password
- first_name
- last_name
- is_staff
- is_active
- date_joined

#### **Customer**
- **customer_id** (PK)
- **user_id** (FK → User)
- profile_pic
- region
- province
- citymun
- barangay
- street_address
- postal_code
- mobile
- created_at
- updated_at

#### **SavedAddress**
- **address_id** (PK)
- **customer_id** (FK → Customer)
- region
- province
- citymun
- barangay
- street_address
- postal_code
- is_default
- created_at
- updated_at

---

### **2. MANAGE PRODUCTS**

#### **Product**
- **product_id** (PK)
- name
- description
- price
- category
- image
- is_active
- created_at
- updated_at
- sizes
- colors

#### **ProductReview**
- **review_id** (PK)
- **customer_id** (FK → Customer)
- **product_id** (FK → Product)
- rating (1-5)
- review_text
- created_at
- updated_at

#### **Wishlist**
- **wishlist_id** (PK)
- **customer_id** (FK → Customer)
- **product_id** (FK → Product)
- created_at

---

### **3. MANAGE ORDERS**

#### **Orders**
- **order_id** (PK)
- **customer_id** (FK → Customer)
- order_ref
- status (Pending, Processing, Out for Delivery, Delivered, Cancelled)
- total_amount
- payment_method
- payment_status
- shipping_address
- shipping_fee
- delivery_date
- delivery_proof_photo
- customer_received_at
- created_at
- updated_at
- cancelled_at
- cancellation_reason

#### **OrderItem**
- **order_item_id** (PK)
- **order_id** (FK → Orders)
- **product_id** (FK → Product)
- quantity
- price
- size
- created_at

#### **CartItem**
- **cart_item_id** (PK)
- **customer_id** (FK → Customer)
- **product_id** (FK → Product)
- size
- quantity
- created_at

#### **DeliveryStatusLog**
- **log_id** (PK)
- **order_id** (FK → Orders)
- previous_status
- new_status
- updated_by
- update_method
- notes
- timestamp

#### **DeliveryMagicLink**
- **link_id** (PK)
- **order_id** (FK → Orders) [One-to-One]
- token
- created_at
- expires_at
- is_active

---

### **4. MANAGE PAYMENT**

#### **Payment** (Embedded in Orders)
- payment_method (GCash, Cash on Delivery, Bank Transfer)
- payment_status (Pending, Paid, Failed, Refunded)
- payment_date
- transaction_id
- amount_paid

#### **ShippingFee**
- **shipping_fee_id** (PK)
- courier
- origin_region
- destination_region
- weight_kg
- price_php

---

### **5. MANAGE INVENTORY**

#### **InventoryItem**
- **inventory_id** (PK)
- **product_id** (FK → Product)
- size
- color
- quantity
- reserved_quantity
- updated_at

#### **BulkOrderOperation**
- **operation_id** (PK)
- **performed_by** (FK → User)
- operation_type
- parameters (JSON)
- created_at
- completed_at
- success_count
- error_count
- errors (JSON)

---

### **6. MANAGE REPORTS**

#### **Feedback**
- **feedback_id** (PK)
- **customer_id** (FK → Customer)
- subject
- message
- created_at
- is_resolved

#### **Newsletter**
- **newsletter_id** (PK)
- email
- is_active
- created_at

#### **ChatSession**
- **session_id** (PK)
- session_identifier
- **customer_id** (FK → Customer)
- **admin_user_id** (FK → User)
- handover_status
- is_active
- created_at
- updated_at
- handover_requested_at
- admin_joined_at

#### **ChatMessage**
- **message_id** (PK)
- **session_id** (FK → ChatSession)
- **admin_user_id** (FK → User)
- message_type
- content
- timestamp
- is_helpful

#### **ChatbotKnowledge**
- **knowledge_id** (PK)
- category
- keywords
- question
- answer
- is_active
- created_at
- updated_at

#### **Address** (Admin System)
- **address_id** (PK)
- region
- province
- city_municipality
- barangay
- street
- postal_code

---

## **RELATIONSHIPS**

### **One-to-One (1:1):**
- User ↔ Customer
- Orders ↔ DeliveryMagicLink

### **One-to-Many (1:N):**

#### **MANAGE ACCOUNTS:**
- User → Customer (1:1)
- Customer → SavedAddress (1:N)

#### **MANAGE PRODUCTS:**
- Product → ProductReview (1:N)
- Customer → ProductReview (1:N)
- Product → Wishlist (1:N)
- Customer → Wishlist (1:N)

#### **MANAGE ORDERS:**
- Customer → Orders (1:N)
- Customer → CartItem (1:N)
- Orders → OrderItem (1:N)
- Product → OrderItem (1:N)
- Product → CartItem (1:N)
- Orders → DeliveryStatusLog (1:N)

#### **MANAGE INVENTORY:**
- Product → InventoryItem (1:N)
- User → BulkOrderOperation (1:N)

#### **MANAGE REPORTS:**
- Customer → Feedback (1:N)
- Customer → ChatSession (1:N)
- User → ChatSession (1:N) [as admin]
- ChatSession → ChatMessage (1:N)
- User → ChatMessage (1:N) [as admin]

### **Many-to-Many (M:N):**
- Orders ↔ BulkOrderOperation (through intermediate table)

---

## **USE CASE TO ENTITY MAPPING**

### **1. Manage Accounts**
- **Primary Entities:** User, Customer, SavedAddress
- **Operations:** Create, Read, Update, Delete user accounts and customer profiles
- **Key Features:**
  - User authentication and authorization
  - Customer profile management
  - Multiple saved addresses per customer
  - Address validation and management

### **2. Manage Products**
- **Primary Entities:** Product, ProductReview, Wishlist, InventoryItem
- **Operations:** Add, edit, delete products; manage reviews and wishlists
- **Key Features:**
  - Product catalog management
  - Customer reviews and ratings
  - Wishlist functionality
  - Product variants (size, color)

### **3. Manage Orders**
- **Primary Entities:** Orders, OrderItem, CartItem, DeliveryStatusLog, DeliveryMagicLink
- **Operations:** Process orders, track delivery, manage cart, update order status
- **Key Features:**
  - Shopping cart functionality
  - Order processing and tracking
  - Delivery status management
  - Customer receipt confirmation with photo proof
  - Magic links for external delivery updates

### **4. Manage Payment**
- **Primary Entities:** Orders (payment fields), ShippingFee
- **Operations:** Process payments, calculate shipping fees, handle transactions
- **Key Features:**
  - Multiple payment methods (GCash, COD, Bank Transfer)
  - Payment status tracking
  - Shipping fee calculations
  - Transaction management

### **5. Manage Inventory**
- **Primary Entities:** InventoryItem, BulkOrderOperation
- **Operations:** Track stock levels, manage inventory, bulk operations
- **Key Features:**
  - Real-time inventory tracking
  - Stock level management per product variant
  - Reserved quantity for pending orders
  - Bulk inventory operations

### **6. Manage Reports**
- **Primary Entities:** Feedback, Newsletter, ChatSession, ChatMessage, ChatbotKnowledge
- **Operations:** Generate reports, manage customer support, handle communications
- **Key Features:**
  - Customer feedback system
  - Newsletter management
  - AI chatbot with admin handover
  - Customer support chat system
  - Knowledge base management

---

## **KEY BUSINESS RULES**

### **Account Management:**
1. Each User can have one Customer profile
2. Customers can have multiple saved addresses
3. One address can be set as default per customer
4. User authentication is required for customer operations

### **Product Management:**
1. Products can have multiple inventory items (size/color variants)
2. Each product can have multiple reviews from different customers
3. Customers can only review products once
4. Products can be added to multiple wishlists

### **Order Management:**
1. Orders contain multiple OrderItems
2. Each OrderItem references a specific product
3. Order status follows a defined workflow: Pending → Processing → Out for Delivery → Delivered
4. Customers can confirm receipt with photo proof
5. Delivery status changes are logged for audit trail

### **Payment Management:**
1. Each order has payment information
2. Payment status is tracked separately from order status
3. Shipping fees are calculated based on region and weight
4. Multiple payment methods are supported

### **Inventory Management:**
1. Stock levels are tracked per product variant (size/color)
2. Reserved quantity prevents overselling
3. Inventory updates can be performed in bulk
4. Stock levels are automatically adjusted on order placement

### **Report Management:**
1. Customer interactions are logged for analysis
2. Chat sessions can be transferred from bot to admin
3. Feedback is categorized and tracked for resolution
4. Newsletter subscriptions are managed separately

---

## **DATA INTEGRITY CONSTRAINTS**

### **Primary Keys:**
- All entities have auto-incrementing primary keys
- Primary keys ensure unique identification of records

### **Foreign Keys:**
- Maintain referential integrity between related entities
- Cascade delete rules protect data consistency
- Foreign key constraints prevent orphaned records

### **Unique Constraints:**
- Customer can only review each product once
- Customer can only add each product to wishlist once
- Email addresses in newsletter are unique
- Order reference numbers are unique

### **Check Constraints:**
- Rating values must be between 1 and 5
- Quantity values must be positive
- Price values must be non-negative
- Status values must match predefined choices

---

## **SYSTEM FEATURES SUPPORTED**

### **Customer Features:**
- Account registration and management
- Product browsing and searching
- Shopping cart and wishlist
- Order placement and tracking
- Payment processing
- Product reviews and ratings
- Customer support chat
- Order receipt confirmation

### **Admin Features:**
- User and customer management
- Product catalog management
- Inventory tracking and management
- Order processing and fulfillment
- Payment and shipping management
- Customer support and chat handover
- Reporting and analytics
- Bulk operations

### **System Features:**
- Real-time inventory updates
- Automated delivery tracking
- AI chatbot with knowledge base
- Email newsletter system
- Audit logging for order changes
- Magic links for external integrations
- Photo upload for delivery proof

---

## **TECHNICAL IMPLEMENTATION NOTES**

### **Django Models:**
- All entities are implemented as Django models
- Foreign key relationships use Django's ORM
- Model validation ensures data integrity
- Custom model methods provide business logic

### **Database Design:**
- Normalized database structure
- Efficient indexing on foreign keys
- JSON fields for flexible data storage
- Timestamp fields for audit trails

### **Security Considerations:**
- User authentication and authorization
- CSRF protection for forms
- File upload validation
- SQL injection prevention through ORM

### **Performance Optimizations:**
- Database indexing on frequently queried fields
- Efficient query optimization
- Caching for frequently accessed data
- Pagination for large datasets

---

*This ERD documentation provides a comprehensive overview of the e-commerce system's database structure, supporting all identified use cases and business requirements.*