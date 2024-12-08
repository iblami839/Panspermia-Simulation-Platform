;; space-mission-data contract

(define-data-var next-data-id uint u0)

(define-map mission-data
  { data-id: uint }
  {
    submitter: principal,
    mission-name: (string-utf8 100),
    data-type: (string-ascii 50),
    data-hash: (buff 32),
    timestamp: uint
  }
)

(define-public (submit-mission-data (mission-name (string-utf8 100)) (data-type (string-ascii 50)) (data-hash (buff 32)))
  (let
    (
      (data-id (var-get next-data-id))
    )
    (map-set mission-data
      { data-id: data-id }
      {
        submitter: tx-sender,
        mission-name: mission-name,
        data-type: data-type,
        data-hash: data-hash,
        timestamp: block-height
      }
    )
    (var-set next-data-id (+ data-id u1))
    (ok data-id)
  )
)

(define-read-only (get-mission-data (data-id uint))
  (map-get? mission-data { data-id: data-id })
)

