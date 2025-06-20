(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-status (err u103))
(define-constant err-already-exists (err u104))
(define-constant err-invalid-participant (err u105))

(define-data-var next-product-id uint u1)
(define-data-var next-shipment-id uint u1)

(define-map products
  { product-id: uint }
  {
    name: (string-ascii 50),
    manufacturer: principal,
    created-at: uint,
    current-owner: principal,
    status: (string-ascii 20)
  }
)

(define-map shipments
  { shipment-id: uint }
  {
    product-id: uint,
    from: principal,
    to: principal,
    carrier: principal,
    status: (string-ascii 20),
    created-at: uint,
    delivered-at: (optional uint)
  }
)

(define-map authorized-participants
  { participant: principal }
  { role: (string-ascii 20) }
)

(define-map product-history
  { product-id: uint, event-id: uint }
  {
    event-type: (string-ascii 30),
    actor: principal,
    timestamp: uint,
    details: (string-ascii 100)
  }
)

(define-data-var next-event-id uint u1)

(define-read-only (get-product (product-id uint))
  (map-get? products { product-id: product-id })
)

(define-read-only (get-shipment (shipment-id uint))
  (map-get? shipments { shipment-id: shipment-id })
)

(define-read-only (get-participant-role (participant principal))
  (map-get? authorized-participants { participant: participant })
)

(define-read-only (get-product-event (product-id uint) (event-id uint))
  (map-get? product-history { product-id: product-id, event-id: event-id })
)

(define-read-only (get-next-product-id)
  (var-get next-product-id)
)

(define-read-only (get-next-shipment-id)
  (var-get next-shipment-id)
)

(define-public (authorize-participant (participant principal) (role (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set authorized-participants
      { participant: participant }
      { role: role }
    ))
  )
)

(define-public (create-product (name (string-ascii 50)))
  (let
    (
      (product-id (var-get next-product-id))
      (participant-role (get-participant-role tx-sender))
    )
    (asserts! (is-some participant-role) err-unauthorized)
    (asserts! (is-eq (get role (unwrap-panic participant-role)) "manufacturer") err-unauthorized)
    
    (map-set products
      { product-id: product-id }
      {
        name: name,
        manufacturer: tx-sender,
        created-at: stacks-block-height,
        current-owner: tx-sender,
        status: "manufactured"
      }
    )
    
    (unwrap-panic (add-product-event product-id "manufactured" tx-sender "Product created"))
    (var-set next-product-id (+ product-id u1))
    (ok product-id)
  )
)

(define-public (create-shipment (product-id uint) (to principal) (carrier principal))
  (let
    (
      (shipment-id (var-get next-shipment-id))
      (product (unwrap! (get-product product-id) err-not-found))
      (sender-role (get-participant-role tx-sender))
      (carrier-role (get-participant-role carrier))
      (recipient-role (get-participant-role to))
    )
    (asserts! (is-some sender-role) err-unauthorized)
    (asserts! (is-some carrier-role) err-unauthorized)
    (asserts! (is-some recipient-role) err-unauthorized)
    (asserts! (is-eq (get current-owner product) tx-sender) err-unauthorized)
    (asserts! (is-eq (get role (unwrap-panic carrier-role)) "carrier") err-invalid-participant)
    
    (map-set shipments
      { shipment-id: shipment-id }
      {
        product-id: product-id,
        from: tx-sender,
        to: to,
        carrier: carrier,
        status: "in-transit",
        created-at: stacks-block-height,
        delivered-at: none
      }
    )
    
    (map-set products
      { product-id: product-id }
      (merge product { status: "in-transit" })
    )
    
    (unwrap-panic (add-product-event product-id "shipped" tx-sender "Product shipped"))
    (var-set next-shipment-id (+ shipment-id u1))
    (ok shipment-id)
  )
)

(define-public (update-shipment-status (shipment-id uint) (new-status (string-ascii 20)))
  (let
    (
      (shipment (unwrap! (get-shipment shipment-id) err-not-found))
      (carrier-role (get-participant-role tx-sender))
    )
    (asserts! (is-some carrier-role) err-unauthorized)
    (asserts! (is-eq (get role (unwrap-panic carrier-role)) "carrier") err-unauthorized)
    (asserts! (is-eq (get carrier shipment) tx-sender) err-unauthorized)
    
    (map-set shipments
      { shipment-id: shipment-id }
      (merge shipment { status: new-status })
    )
    
    (unwrap-panic (add-product-event 
      (get product-id shipment) 
      "status-updated" 
      tx-sender 
      new-status
    ))
    (ok true)
  )
)

(define-public (deliver-shipment (shipment-id uint))
  (let
    (
      (shipment (unwrap! (get-shipment shipment-id) err-not-found))
      (product (unwrap! (get-product (get product-id shipment)) err-not-found))
      (carrier-role (get-participant-role tx-sender))
    )
    (asserts! (is-some carrier-role) err-unauthorized)
    (asserts! (is-eq (get role (unwrap-panic carrier-role)) "carrier") err-unauthorized)
    (asserts! (is-eq (get carrier shipment) tx-sender) err-unauthorized)
    (asserts! (is-eq (get status shipment) "in-transit") err-invalid-status)
    
    (map-set shipments
      { shipment-id: shipment-id }
      (merge shipment { 
        status: "delivered",
        delivered-at: (some stacks-block-height)
      })
    )
    
    (map-set products
      { product-id: (get product-id shipment) }
      (merge product { 
        current-owner: (get to shipment),
        status: "delivered"
      })
    )
    
    (unwrap-panic (add-product-event 
      (get product-id shipment) 
      "delivered" 
      tx-sender 
      "Product delivered"
    ))
    (ok true)
  )
)

(define-public (receive-shipment (shipment-id uint))
  (let
    (
      (shipment (unwrap! (get-shipment shipment-id) err-not-found))
      (product (unwrap! (get-product (get product-id shipment)) err-not-found))
    )
    (asserts! (is-eq (get to shipment) tx-sender) err-unauthorized)
    (asserts! (is-eq (get status shipment) "delivered") err-invalid-status)
    
    (map-set products
      { product-id: (get product-id shipment) }
      (merge product { status: "received" })
    )
    
    (unwrap-panic (add-product-event 
      (get product-id shipment) 
      "received" 
      tx-sender 
      "Product received and confirmed"
    ))
    (ok true)
  )
)

(define-private (add-product-event (product-id uint) (event-type (string-ascii 30)) (actor principal) (details (string-ascii 100)))
  (let
    (
      (event-id (var-get next-event-id))
    )
    (map-set product-history
      { product-id: product-id, event-id: event-id }
      {
        event-type: event-type,
        actor: actor,
        timestamp: stacks-block-height,
        details: details
      }
    )
    (var-set next-event-id (+ event-id u1))
    (ok event-id)
  )
)

(define-public (verify-product-authenticity (product-id uint))
  (let
    (
      (product (unwrap! (get-product product-id) err-not-found))
    )
    (ok {
      product-id: product-id,
      manufacturer: (get manufacturer product),
      current-owner: (get current-owner product),
      status: (get status product),
      created-at: (get created-at product)
    })
  )
)

(define-read-only (get-product-chain (product-id uint))
  (let
    (
      (product (unwrap! (get-product product-id) err-not-found))
    )
    (ok {
      product: product,
      manufacturer-verified: (is-some (get-participant-role (get manufacturer product)))
    })
  )
)

(begin
  (map-set authorized-participants
    { participant: contract-owner }
    { role: "admin" }
  )
)