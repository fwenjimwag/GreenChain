;; REC Marketplace Contract

(define-constant err-invalid-price (err u100))
(define-constant err-listing-not-found (err u101))
(define-constant err-unauthorized (err u102))

(define-map listings
  { listing-id: uint }
  { seller: principal, amount: uint, price-per-token: uint }
)

(define-data-var next-listing-id uint u0)

(define-public (create-listing (amount uint) (price-per-token uint))
  (let
    (
      (listing-id (var-get next-listing-id))
    )
    (asserts! (> price-per-token u0) err-invalid-price)
    (try! (contract-call? .rec-token transfer amount tx-sender (as-contract tx-sender)))
    (map-set listings
      { listing-id: listing-id }
      { seller: tx-sender, amount: amount, price-per-token: price-per-token }
    )
    (var-set next-listing-id (+ listing-id u1))
    (ok listing-id)
  )
)

(define-public (cancel-listing (listing-id uint))
  (let
    (
      (listing (unwrap! (map-get? listings { listing-id: listing-id }) err-listing-not-found))
    )
    (asserts! (is-eq (get seller listing) tx-sender) err-unauthorized)
    (try! (as-contract (contract-call? .rec-token transfer (get amount listing) tx-sender (get seller listing))))
    (map-delete listings { listing-id: listing-id })
    (ok true)
  )
)

(define-public (fulfill-listing (listing-id uint) (amount uint))
  (let
    (
      (listing (unwrap! (map-get? listings { listing-id: listing-id }) err-listing-not-found))
      (total-cost (* amount (get price-per-token listing)))
    )
    (asserts! (<= amount (get amount listing)) err-invalid-price)
    (try! (stx-transfer? total-cost tx-sender (get seller listing)))
    (try! (as-contract (contract-call? .rec-token transfer amount tx-sender tx-sender)))
    (if (< amount (get amount listing))
      (map-set listings
        { listing-id: listing-id }
        (merge listing { amount: (- (get amount listing) amount) })
      )
      (map-delete listings { listing-id: listing-id })
    )
    (ok true)
  )
)

(define-read-only (get-listing (listing-id uint))
  (map-get? listings { listing-id: listing-id })
)

