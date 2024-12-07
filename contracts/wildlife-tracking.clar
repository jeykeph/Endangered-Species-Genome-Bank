;; wildlife-tracking contract

(define-map tracking-data
  { tracking-id: uint }
  {
    species: (string-ascii 100),
    location: (tuple (latitude int) (longitude int)),
    timestamp: uint,
    metadata: (string-utf8 1024)
  }
)

(define-data-var last-tracking-id uint u0)

(define-constant contract-owner tx-sender)

(define-public (record-tracking-data (species (string-ascii 100)) (latitude int) (longitude int) (metadata (string-utf8 1024)))
  (let
    (
      (tracking-id (+ (var-get last-tracking-id) u1))
    )
    (map-set tracking-data
      { tracking-id: tracking-id }
      {
        species: species,
        location: { latitude: latitude, longitude: longitude },
        timestamp: block-height,
        metadata: metadata
      }
    )
    (var-set last-tracking-id tracking-id)
    (ok tracking-id)
  )
)

(define-read-only (get-tracking-data (tracking-id uint))
  (map-get? tracking-data { tracking-id: tracking-id })
)

(define-read-only (get-latest-tracking-id)
  (ok (var-get last-tracking-id))
)

