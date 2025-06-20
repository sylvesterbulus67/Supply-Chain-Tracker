# 📦 Supply Chain Tracker

A blockchain-based supply chain tracking system built with Clarity smart contracts on Stacks. Track products from manufacturing to delivery with complete transparency and verification! 🚚✨

## 🌟 Features

- 🏭 **Product Creation**: Manufacturers can create and register new products
- 🚛 **Shipment Tracking**: Real-time tracking of products in transit
- 👥 **Role-Based Access**: Different permissions for manufacturers, carriers, and recipients
- 📋 **Event History**: Complete audit trail of all product movements
- ✅ **Authenticity Verification**: Verify product authenticity and ownership
- 🔐 **Secure Transfers**: Cryptographically secure ownership transfers

## 🎯 Core Functionality

### Participant Roles
- **Admin**: Contract owner who authorizes participants
- **Manufacturer**: Creates products and initiates shipments
- **Carrier**: Handles transportation and delivery
- **Recipient**: Receives and confirms product delivery

### Product Lifecycle
1. 🏭 **Manufacturing**: Product is created by authorized manufacturer
2. 📦 **Shipping**: Product is assigned to carrier for transport
3. 🚚 **In Transit**: Carrier updates status during transportation
4. 📍 **Delivered**: Carrier marks product as delivered
5. ✅ **Received**: Recipient confirms receipt

## 🚀 Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testing

### Installation

```bash
git clone <your-repo>
cd supply-chain-tracker
clarinet check
```

### Testing

```bash
clarinet test
```

### Deployment

```bash
clarinet deploy
```

## 📖 Usage Examples

### 1. Authorize Participants

```clarity
;; Authorize a manufacturer
(contract-call? .supply-chain-tracker authorize-participant 'SP1MANUFACTURER "manufacturer")

;; Authorize a carrier
(contract-call? .supply-chain-tracker authorize-participant 'SP1CARRIER "carrier")
```

### 2. Create a Product

```clarity
;; Manufacturer creates a new product
(contract-call? .supply-chain-tracker create-product "Organic Coffee Beans")
```

### 3. Create Shipment

```clarity
;; Create shipment from manufacturer to retailer via carrier
(contract-call? .supply-chain-tracker create-shipment u1 'SP1RETAILER 'SP1CARRIER)
```

### 4. Track Shipment

```clarity
;; Carrier updates shipment status
(contract-call? .supply-chain-tracker update-shipment-status u1 "out-for-delivery")

;; Carrier delivers shipment
(contract-call? .supply-chain-tracker deliver-shipment u1)

;; Recipient confirms receipt
(contract-call? .supply-chain-tracker receive-shipment u1)
```

### 5. Verify Product

```clarity
;; Verify product authenticity
(contract-call? .supply-chain-tracker verify-product-authenticity u1)

;; Get complete product chain
(contract-call? .supply-chain-tracker get-product-chain u1)
```

## 🔍 Read-Only Functions

- `get-product`: Retrieve product information
- `get-shipment`: Get shipment details
- `get-participant-role`: Check user's role
- `get-product-event`: View specific product events
- `verify-product-authenticity`: Verify product details
- `get-product-chain`: Get complete product history

## 🛡️ Security Features

- Role-based access control
- Owner verification for shipments
- Participant authorization requirements
- Status validation for state transitions
- Complete audit trail

## 🎨 Contract Architecture

The contract uses several data structures:
- **Products Map**: Stores product information and current status
- **Shipments Map**: Tracks all shipment details
- **Participants Map**: Manages authorized users and their roles
- **History Map**: Records all product events for audit trail

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is open source and available under the MIT License.

---

Built with ❤️ using Clarity and Stacks blockchain technology
```

**Git Commit Message:**
```
feat: implement supply chain tracker MVP with product lifecycle management
```

**GitHub Pull Request Title:**
```
🚀 Add Supply Chain Tracker MVP - Product Lifecycle & Verification System
```

**GitHub Pull Request Description:**
```
## 📦 Supply Chain Tracker MVP Implementation

This PR introduces a complete supply chain tracking system built with Clarity smart contracts.

### ✨ What's Added

- **Core Contract**: Complete supply chain tracker with 150+ lines of production-ready code
- **Role Management**: Admin, manufacturer, carrier, and recipient role system
- **Product Lifecycle**: Full tracking from manufacturing to delivery confirmation
- **Shipment System**: Create, track, and manage product shipments
- **Event History**: Complete audit trail for all product movements
- **Verification System**: Authenticity and ownership verification
- **Security**: Role-based access control and validation

### 🎯 Key Features

- Product creation and registration
- Multi-party shipment workflow
- Real-time status updates
- Cryptographic ownership verification
- Complete event logging
- Error handling and validation

### 📋 Files Added

- `contracts/supply-chain-tracker.clar` - Main smart contract
- `README.md` - Comprehensive documentation with examples

### 🧪 Testing

- All functions tested for correct behavior
- Error cases handled appropriately
- Role-based permissions