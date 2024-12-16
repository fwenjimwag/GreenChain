;; REC Issuance Contract

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-energy-amount (err u101))

(define-map energy-producers principal bool)

(define-public (register-energy-producer (producer principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set energy-producers producer true))
  )
)

(define-public (issue-rec (energy-amount uint))
  (let
    (
      (producer tx-sender)
      (rec-amount (* energy-amount u1000)) ;; 1 REC per 1000 kWh
    )
    (asserts! (is-some (map-get? energy-producers producer)) err-owner-only)
    (asserts! (> energy-amount u0) err-invalid-energy-amount)
    (as-contract (contract-call? .rec-token mint rec-amount producer))
  )
)

(define-read-only (is-energy-producer (producer principal))
  (default-to false (map-get? energy-producers producer))
)

