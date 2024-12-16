;; REC Token Contract

(define-fungible-token rec-token)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? rec-token amount recipient)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (ft-transfer? rec-token amount sender recipient)
  )
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance rec-token account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply rec-token))
)

