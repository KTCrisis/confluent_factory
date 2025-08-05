# Confluent Terraform Factory

## 🌐 Overview

This Confluent factory enables automated provisioning of Confluent Cloud resources via Terraform. It's designed to be triggered from source projects via GitLab CI pipelines, providing a centralized and standardized approach for Kafka resource management.

## 🏗️ Architecture

```
┌─────────────────┐    trigger    ┌─────────────────────┐
│  Source Project │──────────────►│  Terraform Factory  │
│                 │               │                     │
│ factory-config  │               │  ┌─────────────────┐│
│ schemas/        │               │  │   Modules       ││
│ connectors/     │               │  │                 ││
│ flink/          │               │  │ • Environment   ││
└─────────────────┘               │  │ • Cluster       ││
                                  │  │ • Topics        ││
                                  │  │ • Schema Reg.   ││
                                  │  │ • API Keys      ││
                                  │  │ • ACLs          ││
                                  │  │ • Connectors    ││
                                  │  │ • ksqlDB        ││
                                  │  │ • Flink         ││
                                  │  └─────────────────┘│
                                  └─────────────────────┘
```

## 📋 Prerequisites

### Factory Project
- GitLab Runner with Docker access
- Configured GitLab CI variables:
  - `CONFLUENT_CLOUD_API_KEY`
  - `CONFLUENT_CLOUD_API_SECRET`
  - `TF_HTTP_USERNAME`
  - `TF_HTTP_PASSWORD`
  - Environment-specific API variables (auto-generated)

### Source Project
- Configured `factory-config.yml` file
- `schemas/`, `connectors/`, and `flink/` directories if needed
- GitLab CI pipeline configured to trigger factory

## 🚀 Quick Start

### 1. Source Project Configuration

Create your `factory-config.yml` file:

```yaml
project:
  name: "my-project"
  environment: "MFS-dev"
  cluster: "cluster-dev"
  team: "data-team"
  domain: "Data"
  cost_center: "IRN12345"
  owner: "team-lead"

resources:
  # Topics following naming convention
  topics:
    - name: "corp.dev.mfs.kafka.raw.billing.v1.log"
      partitions: 3
      retention_ms: 604800000
      cleanup_policy: "delete"
  
  # Schema Registry subjects
  schema_registry:
    - subject_name: "corp.dev.mfs.kafka.raw.billing.v1.log-value"
      subject_format: "AVRO"
      subject_path: "./schemas/avro/billing-schema.avsc"
  
  # ksqlDB cluster configuration
  ksqldb:
    cluster_name: "ksqldb-analytics"
    csu: 2
  
  # ACLs with wildcard support
  acl:
    acl_to_produce:
      topics_prefixes: ["corp.dev.mfs.kafka.raw.*", "corp.dev.mfs.kafka.refined.*"]
    acl_to_consume:
      topics_prefixes: ["corp.dev.mfs.kafka.*"]
```

### 2. GitLab CI Pipeline Configuration

Create `.gitlab-ci.yml` in your project:

```yaml
include:
  - local: 'terraform-ci.yml'

variables:
  FACTORY_PROJECT_ID: "irn-79267/kafka-iam-and-observability"
  FACTORY_BRANCH: "main"

stages:
  - prepare
  - trigger
```

### 3. Deploy

1. Commit your files
2. Launch pipeline via GitLab interface
3. Pipeline automatically triggers factory
4. Manually approve the `apply` stage

## 🔄 Pipeline Stages

### Factory Pipeline

1. **Read Config**: Retrieve configuration from source project
2. **Prepare Plan**: Tag validation and preparation
3. **Plan**: Generate Terraform execution plan
4. **Apply**: Apply changes (manual approval required)

### Terraform States

- Storage in GitLab HTTP backend
- State name: `${SOURCE_PROJECT_NAME}_${SOURCE_COMMIT_BRANCH}.tfstate`
- Automatic locking via GitLab API

## 📁 Module Structure

```
modules/
├── confluent_environment/          # Environment creation
├── confluent_cluster/              # Kafka clusters
├── confluent_topics/               # Kafka topics
├── confluent_schema_registry/      # Avro/JSON/Protobuf schemas
├── confluent_service_account/      # Service accounts
├── confluent_api_key/              # API keys
├── confluent_acl/                  # ACL permissions
├── confluent_rolebinding_access_control/ # RBAC
├── confluent_connector/            # Connectors
├── confluent_ksql/                 # ksqlDB clusters
├── confluent_flink/                # Flink pools
├── confluent_flink_statement/      # Flink SQL statements
├── confluent_network_psc/          # Private networks
├── confluent_network_link_access/  # Network access
├── confluent_tags/                 # Metadata tags
└── confluent_topic_tags/           # Topic-tag associations
```

## 📝 Topic Naming Convention

**Follow the standard pattern:**
`<Country Code>.<Env>.<ProducerOwner>.<Domain>.<Topic Layer>.<Topic name>.v<Topic Version>.<Topic kind>`

**Examples:**
- `corp.dev.mfs.kafka.raw.billing.v1.log`
- `fr.prod.finance.payments.refined.transactions.v2.event`
- `us.test.analytics.user.aggregated.sessions.v1.table`

**Components:**
- **Country Code**: `corp`, `fr`, `us`, `de`, etc.
- **Environment**: `dev`, `test`, `prod`, `staging`
- **Producer Owner**: Team/service owning the topic
- **Domain**: Business domain (finance, analytics, etc.)
- **Topic Layer**: `raw`, `refined`, `aggregated`
- **Topic Name**: Descriptive name
- **Version**: `v1`, `v2`, etc.
- **Topic Kind**: `log`, `event`, `table`, `changelog`

## 🔐 Security and Best Practices

### Secret Management
- ✅ All API keys stored as GitLab CI variables
- ✅ Terraform variables marked `sensitive = true`
- ✅ Use of `nonsensitive()` only for outputs
- ✅ Separate sensitive/non-sensitive configs for connectors

### Access and Permissions
- Limited access to CI/CD variables
- Regular API key rotation
- Least privilege principle for service accounts

## 📊 Supported Environments

- **dev**: Development
- **int**: Integration
- **sta**: Staging
- **ope**: Production
- **debug**: Testing and debugging

Each environment has:
- Its own Confluent cluster
- Its own service accounts
- Its own API keys
- Its isolated Terraform state

## 🔧 Advanced Configuration

### ksqlDB Clusters

Configure ksqlDB for stream processing:

```yaml
resources:
  ksqldb:
    cluster_name: "analytics-ksqldb"
    csu: 4                          # Confluent Streaming Units
    service_account: "ksql-sa"      # Optional custom SA
```

**Features:**
- Automatic service account creation
- Environment admin permissions
- Integration with Kafka cluster
- Schema Registry access

### Custom Connectors

```yaml
connectors:
  source:
    - name: "billing-source-connector"
      path: "./connectors/source/datagen"
  sink:
    - name: "analytics-sink-connector"
      path: "./connectors/sink/BigQuery"
```

Required structure:
```
connectors/source/datagen/
├── config_nonsensitive.json
└── config_sensitive.json
```

### Flink SQL Statements

```yaml
flink_statements:
  - name: "billing-aggregation"
    statement_path: "./flink/statements/billing-agg.sql"
```

Example Flink SQL:
```sql
CREATE TABLE billing_events (
  transaction_id STRING,
  amount DECIMAL(10,2),
  currency STRING,
  event_time TIMESTAMP(3),
  WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
  'connector' = 'kafka',
  'topic' = 'corp.prod.mfs.kafka.raw.billing.v1.log',
  'properties.bootstrap.servers' = 'pkc-xxxxx.region.provider.confluent.cloud:9092'
);
```

### Schema References

```yaml
schema_registry:
  - subject_name: "order-value"
    subject_format: "AVRO"
    subject_path: "./schemas/order.avsc"
    schema_references:
      - name: "address"
        subject_name: "address-value"
        version: 1
```

### Wildcard ACLs

The factory supports wildcard patterns in ACL configurations:

```yaml
acl:
  acl_to_produce:
    topics_prefixes: 
      - "corp.prod.mfs.kafka.raw.*"      # All raw topics
      - "corp.prod.mfs.kafka.refined.*"  # All refined topics
      - "corp.prod.analytics.*"          # All analytics topics
  
  acl_to_consume:
    topics_prefixes:
      - "corp.prod.mfs.kafka.*"          # All MFS topics
      - "corp.prod.finance.payments.*"   # All payment topics
      - "*billing*"                      # Any topic containing 'billing'
```

**Wildcard Patterns:**
- `*` matches any sequence of characters
- `?` matches any single character
- Patterns are matched as prefixes by default
- Use with caution in production environments

## 🏷️ Automatic Tagging System

Tags are automatically generated from configuration file:

- **team_tag**: `${team}_team`
- **environment_tag**: `${env_suffix}_environment`
- **cost_center_tag**: `${cost_center}_cost_center`
- **domain_tag**: `${domain}_domain`
- **owner_tag**: `${owner}_owner`

These tags are automatically applied to created topics and enable:
- Cost tracking and allocation
- Resource governance
- Compliance auditing
- Search and discovery

## 🚨 Troubleshooting

### Common Errors

1. **Pipeline not triggering**
   ```bash
   # Check cross-project permissions
   # Verify FACTORY_PROJECT_ID variable
   # Ensure factory-config.yml exists
   ```

2. **State lock errors**
   ```bash
   # Force unlock via GitLab API
   curl -X DELETE "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${STATE_NAME}/lock" \
        -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}"
   ```

3. **Missing variables**
   ```bash
   # Check in GitLab UI: Settings > CI/CD > Variables
   # Verify naming: TF_VAR_*_{environment_suffix}
   ```

4. **ksqlDB cluster creation fails**
   ```bash
   # Ensure Kafka cluster exists first
   # Verify service account permissions
   # Check CSU limits for environment
   ```

5. **Topic naming validation**
   ```bash
   # Verify naming convention compliance
   # Check for reserved keywords
   # Validate character set (alphanumeric, dots, hyphens)
   ```

### Logs and Monitoring

- Check pipeline artifacts for details
- `tf_output_credentials.json` contains generated keys
- Terraform plan available in artifacts
- ksqlDB logs available in Confluent Control Center

## 🤝 Contributing

### Adding a New Module

1. Create directory `modules/new_module/`
2. Implement `main.tf`, `variables.tf`, `outputs.tf`, `provider.tf`
3. Add call in main `main.tf`
4. Document in README
5. Test on debug environment

### Pipeline Modifications

1. Modify `*-terraform-ci.yml` files
2. Test with `ENVIRONMENT_NAME=debug`
3. Validate across all environments

### ksqlDB Enhancements

1. Add new ksqlDB features to module
2. Update variable validation
3. Test stream processing capabilities
4. Document new functionality

## 📚 Resources

- [Confluent Provider Documentation](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs)
- [GitLab CI Documentation](https://docs.gitlab.com/ee/ci/)
- [Terraform HTTP Backend](https://www.terraform.io/docs/language/settings/backends/http.html)
- [ksqlDB Documentation](https://docs.ksqldb.io/)
- [Confluent Schema Registry Guide](https://docs.confluent.io/platform/current/schema-registry/)

## 📞 Support

- **Issues**: Create a Jira issue 
- **Contact**: Kafka Platform Team
- **Documentation**: Confluence
- **ksqlDB  & Flink Support**: Kafka Platform Team

---

**Version**: 2.1.0  
**Last Updated**: August 2025  
**Confluent Provider**: 2.1.0  
**Supported Features**: Topics, Schema Registry, ACLs, Connectors, ksqlDB, Flink, RBAC
