;; peer-review contract

(define-data-var next-review-id uint u0)

(define-map reviews
  { review-id: uint }
  {
    reviewer: principal,
    simulation-id: uint,
    rating: uint,
    comments: (string-utf8 1000),
    status: (string-ascii 20)
  }
)

(define-public (submit-review (simulation-id uint) (rating uint) (comments (string-utf8 1000)))
  (let
    (
      (review-id (var-get next-review-id))
    )
    (asserts! (< rating u6) (err u400)) ;; Rating must be between 0 and 5
    (map-set reviews
      { review-id: review-id }
      {
        reviewer: tx-sender,
        simulation-id: simulation-id,
        rating: rating,
        comments: comments,
        status: "submitted"
      }
    )
    (var-set next-review-id (+ review-id u1))
    (ok review-id)
  )
)

(define-read-only (get-review (review-id uint))
  (map-get? reviews { review-id: review-id })
)

(define-public (update-review-status (review-id uint) (new-status (string-ascii 20)))
  (let
    (
      (review (unwrap! (map-get? reviews { review-id: review-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get reviewer review)) (err u403))
    (ok (map-set reviews
      { review-id: review-id }
      (merge review { status: new-status })
    ))
  )
)

