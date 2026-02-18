# Architectural Decision Records

## ADR-001: CfCT over AFT for Control Tower Customizations

**Date**: 2026-01-29  
**Status**: Accepted

### Context
Control Tower offers three customization approaches:
- **CfCT** (Customizations for Control Tower) - CloudFormation-based
- **AFT** (Account Factory for Terraform) - Terraform-based account vending
- **AFC** (Account Factory Customizations) - Console-based blueprints

### Decision
Use CfCT for landing zone customizations, Terraform for workload resources.

### Rationale
1. CfCT handles landing zone concerns (SCPs, Config rules) well
2. Terraform is preferred for workload infrastructure (better state management, modules)
3. AFC development appears stalled (missing features promised for 2023 roadmap)
4. Separating concerns: CfCT for governance, Terraform for resources

### Consequences
- Need to learn CfCT manifest.yaml structure
- Two IaC tools to maintain
- Clear separation of responsibility

---

## ADR-002: Single Region Deployment

**Date**: 2026-01-29  
**Status**: Accepted

### Context
Control Tower can be configured as single-region or multi-region.

### Decision
Deploy single-region (us-east-1) only.

### Rationale
1. AWS Config charges per configuration item per region
2. CloudTrail multi-region increases storage costs
3. No disaster recovery requirements for personal playground
4. us-east-1 has best service availability and pricing

### Consequences
- Cannot test multi-region patterns
- Global services (IAM) still logged once (home region only in LZ 3.0+)
- Can add regions later if needed (with cost increase)

---

## ADR-003: No NAT Gateways

**Date**: 2026-01-29  
**Status**: Accepted

### Context
Private subnets require NAT gateways for outbound internet access.

### Decision
Use public subnets only for sandbox workloads.

### Rationale
1. NAT Gateway costs ~$32/month + data transfer
2. Playground workloads don't require private subnet security
3. VPC Endpoints (gateway type) are free for S3/DynamoDB
4. Can add NAT later if testing requires it

### Consequences
- All EC2/Lambda must have public IPs or use VPC endpoints
- Not representative of production network patterns
- Security groups become primary access control

---

## ADR-004: On-Demand Bedrock Only

**Date**: 2026-01-29  
**Status**: Accepted

### Context
Bedrock offers on-demand (pay-per-token) and provisioned throughput (reserved capacity).

### Decision
Use on-demand pricing exclusively.

### Rationale
1. Provisioned throughput minimum is ~$29K/month
2. On-demand has no commitment, pay only for usage
3. Flex tier offers 50% discount for latency-tolerant workloads
4. Batch mode offers 50% discount for async processing

### Consequences
- May hit rate limits under high load
- Cannot use fine-tuned models (require provisioned)
- Sufficient for experimentation and learning

---

## ADR-005: Daily Config Recording

**Date**: 2026-01-29  
**Status**: Accepted

### Context
AWS Config can record continuously or daily (periodic).

### Decision
Use daily (periodic) recording for sandbox accounts.

### Rationale
1. Continuous recording charges per configuration item
2. High-churn resources (Lambda, containers) generate many CIs
3. Daily recording captures state once per 24 hours
4. Still provides visibility, just not real-time

### Consequences
- Cannot detect rapid configuration changes
- Compliance checks run on daily snapshot
- Security monitoring is delayed (acceptable for playground)

---

## ADR-006: 90-Day Log Retention

**Date**: 2026-01-29  
**Status**: Accepted

### Context
CloudTrail and Config logs can be retained indefinitely.

### Decision
- 30 days in S3 Standard
- 30-60 days in S3 Glacier
- Delete after 90 days

### Rationale
1. No compliance requirements for personal playground
2. S3 storage costs accumulate over time
3. 90 days sufficient for troubleshooting and learning
4. Can adjust if specific compliance testing needed

### Consequences
- Cannot investigate issues older than 90 days
- Reduces S3 storage costs significantly
- Aligns with playground (non-production) purpose
