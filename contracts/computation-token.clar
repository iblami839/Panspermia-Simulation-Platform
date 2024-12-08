;; computation-token contract

(define-fungible-token computation-token)

(define-constant contract-owner tx-sender)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (ft-mint? computation-token amount recipient)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (ft-transfer? computation-token amount sender recipient)
  )
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance computation-token account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply computation-token))
)

