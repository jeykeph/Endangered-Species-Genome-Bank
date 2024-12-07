;; genome-nft contract

(define-non-fungible-token genome-nft uint)

(define-data-var last-token-id uint u0)

(define-map genome-data
  { token-id: uint }
  {
    species: (string-ascii 100),
    sequence-hash: (buff 32),
    metadata-url: (string-utf8 256)
  }
)

(define-public (mint (species (string-ascii 100)) (sequence-hash (buff 32)) (metadata-url (string-utf8 256)))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (try! (nft-mint? genome-nft token-id tx-sender))
    (map-set genome-data
      { token-id: token-id }
      {
        species: species,
        sequence-hash: sequence-hash,
        metadata-url: metadata-url
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (nft-transfer? genome-nft token-id sender recipient)
  )
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? genome-nft token-id))
)

(define-read-only (get-genome-data (token-id uint))
  (map-get? genome-data { token-id: token-id })
)

