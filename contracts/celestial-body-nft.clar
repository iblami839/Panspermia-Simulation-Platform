;; celestial-body-nft contract

(define-non-fungible-token celestial-body uint)

(define-data-var next-token-id uint u0)

(define-map celestial-bodies
  { token-id: uint }
  {
    name: (string-utf8 100),
    body-type: (string-ascii 20),
    characteristics: (list 5 {
      name: (string-ascii 50),
      value: (string-utf8 100)
    })
  }
)

(define-public (mint (name (string-utf8 100)) (body-type (string-ascii 20)) (characteristics (list 5 {name: (string-ascii 50), value: (string-utf8 100)})))
  (let
    (
      (token-id (var-get next-token-id))
    )
    (try! (nft-mint? celestial-body token-id tx-sender))
    (map-set celestial-bodies
      { token-id: token-id }
      {
        name: name,
        body-type: body-type,
        characteristics: characteristics
      }
    )
    (var-set next-token-id (+ token-id u1))
    (ok token-id)
  )
)

(define-read-only (get-celestial-body (token-id uint))
  (map-get? celestial-bodies { token-id: token-id })
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (nft-transfer? celestial-body token-id sender recipient)
  )
)

