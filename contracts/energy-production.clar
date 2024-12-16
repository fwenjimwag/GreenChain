;; Energy Production Integration Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-data (err u101))

(define-map energy-data
  { producer: principal, timestamp: uint }
  { energy-amount: uint }
)

(define-public (record-energy-production (producer principal) (timestamp uint) (energy-amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> energy-amount u0) err-invalid-data)
    (map-set energy-data
      { producer: producer, timestamp: timestamp }
      { energy-amount: energy-amount }
    )
    (ok true)
  )
)

(define-read-only (get-energy-production (producer principal) (timestamp uint))
  (map-get? energy-data { producer: producer, timestamp: timestamp })
)

