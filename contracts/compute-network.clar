;; compute-network contract

(define-map compute-nodes
  { node-id: uint }
  {
    owner: principal,
    capacity: uint,
    reputation: uint
  }
)

(define-map compute-jobs
  { job-id: uint }
  {
    requester: principal,
    node-id: uint,
    status: (string-ascii 20),
    result-hash: (optional (buff 32))
  }
)

(define-data-var last-node-id uint u0)
(define-data-var last-job-id uint u0)

(define-public (register-node (capacity uint))
  (let
    (
      (node-id (+ (var-get last-node-id) u1))
    )
    (map-set compute-nodes
      { node-id: node-id }
      {
        owner: tx-sender,
        capacity: capacity,
        reputation: u0
      }
    )
    (var-set last-node-id node-id)
    (ok node-id)
  )
)

(define-public (submit-job (node-id uint))
  (let
    (
      (job-id (+ (var-get last-job-id) u1))
    )
    (asserts! (is-some (map-get? compute-nodes { node-id: node-id })) (err u404))
    (map-set compute-jobs
      { job-id: job-id }
      {
        requester: tx-sender,
        node-id: node-id,
        status: "submitted",
        result-hash: none
      }
    )
    (var-set last-job-id job-id)
    (ok job-id)
  )
)

(define-public (complete-job (job-id uint) (result-hash (buff 32)))
  (let
    (
      (job (unwrap! (map-get? compute-jobs { job-id: job-id }) (err u404)))
      (node (unwrap! (map-get? compute-nodes { node-id: (get node-id job) }) (err u404)))
    )
    (asserts! (is-eq (get owner node) tx-sender) (err u403))
    (asserts! (is-eq (get status job) "submitted") (err u400))
    (map-set compute-jobs
      { job-id: job-id }
      (merge job {
        status: "completed",
        result-hash: (some result-hash)
      })
    )
    (map-set compute-nodes
      { node-id: (get node-id job) }
      (merge node {
        reputation: (+ (get reputation node) u1)
      })
    )
    (ok true)
  )
)

(define-read-only (get-job (job-id uint))
  (map-get? compute-jobs { job-id: job-id })
)

(define-read-only (get-node (node-id uint))
  (map-get? compute-nodes { node-id: node-id })
)

