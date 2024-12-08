;; c

(define-data-var next-simulation-id uint u0)

(define-map simulations
  { simulation-id: uint }
  {
    creator: principal,
    name: (string-utf8 100),
    description: (string-utf8 500),
    parameters: (list 10 {
      name: (string-ascii 50),
      value: (string-utf8 100)
    }),
    status: (string-ascii 20)
  }
)

(define-public (create-simulation (name (string-utf8 100)) (description (string-utf8 500)) (parameters (list 10 {name: (string-ascii 50), value: (string-utf8 100)})))
  (let
    (
      (simulation-id (var-get next-simulation-id))
    )
    (map-set simulations
      { simulation-id: simulation-id }
      {
        creator: tx-sender,
        name: name,
        description: description,
        parameters: parameters,
        status: "pending"
      }
    )
    (var-set next-simulation-id (+ simulation-id u1))
    (ok simulation-id)
  )
)

(define-read-only (get-simulation (simulation-id uint))
  (map-get? simulations { simulation-id: simulation-id })
)

(define-public (update-simulation-status (simulation-id uint) (new-status (string-ascii 20)))
  (let
    (
      (simulation (unwrap! (map-get? simulations { simulation-id: simulation-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get creator simulation)) (err u403))
    (ok (map-set simulations
      { simulation-id: simulation-id }
      (merge simulation { status: new-status })
    ))
  )
)

