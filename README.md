
## Terraform Factory Pipeline

This factory enables Confluent Cloud resource provisioning through Terraform. It is designed to be triggered from a source project via GitLab CI pipeline.

## 🌐 Overview

The pipeline is triggered by a source project and uses a YAML configuration file to create Terraform resources. States (tfstate) are stored in the GitLab backend, with a separate state file for each project/branch.

## 📋 Prerequisites

- A source project with:
  - A configuration file (`factory-config.yml`)
  - A configured trigger pipeline
- Access to Harbor Docker registry
- GitLab token for Terraform backend access

## 🔄 Pipeline Stages

### 1. Read Config
- **Stage**: `read_config`
- **Purpose**: Retrieve and validate source project configuration
- **Actions**:
  - Fetches configuration file from source project
  - Generates unique Terraform state filename
  - Creates `terraform.env` with environment variables

### 2. Initialize
- **Stage**: `init`
- **Purpose**: Initialize Terraform with GitLab backend
- **Actions**:
  - Configures GitLab HTTP backend
  - Downloads required providers
  - Sets up state locking

### 3. Plan
- **Stage**: `plan`
- **Purpose**: Create Terraform execution plan
- **Actions**:
  - Reads configuration
  - Generates detailed change plan
  - Saves plan for apply stage

### 4. Apply
- **Stage**: `apply`
- **Purpose**: Apply planned changes
- **Action**: Executes Terraform plan
- **Note**: Manual trigger required

### 5. Destroy (Optional)
- **Stage**: `destroy`
- **Purpose**: Remove all resources
- **Action**: Destroys created infrastructure
- **Note**: Manual trigger required

## 🔧 Configuration


## 📤 Triggering from Source Project

1. **Source Project Configuration**:
   ```yaml
   # .gitlab-ci.yml in source project
   trigger_factory:
     stage: trigger
     trigger:
       project: "irn-79267/kafka-iam-and-observability"
       branch: "main"
       strategy: depend
     variables:
       SOURCE_PROJECT_ID: $CI_PROJECT_ID
       SOURCE_COMMIT_BRANCH: $CI_COMMIT_BRANCH
       CONFIG_FILE: "factory-config.yml"
   ```

2. **Required Variables in Source Project**:
   - `SOURCE_PROJECT_ID`: Source project ID
   - `SOURCE_COMMIT_BRANCH`: Source branch
   - `SOURCE_JOB_NAME`: Trigger job name
   - `SOURCE_JOB_ID`: Source job ID

## 📁 Terraform State Structure

- State filename is dynamically generated: `${SOURCE_PROJECT_ID}_${SOURCE_COMMIT_BRANCH}.tfstate`
- Stored in factory project's GitLab backend
- Locks managed via GitLab API

## 🔐 Security

- Pipeline triggered only via trigger (`SOURCE_JOB_NAME == "trigger_factory_pipeline"`)
- Apply and destroy stages protected by manual validation
- Credentials secured via GitLab variables

## ⚠️ Important Notes

1. **Terraform State**:
   - Unique per source project/branch
   - Do not modify manually

2. **Triggering**:
   - Verify cross-project permissions
   - Ensure configuration file is valid

3. **Apply/Destroy**:
   - Manual actions required
   - Verify plan before applying

## 🚀 Usage Example

### 1. Create Configuration File
```yaml
# factory-config.yml
project:
  name: "confluent-billing-mfs"
  environment: "dev"

resources:
  topics:
    - name: "CORP.dev.mfs.kafka.raw.billing.v1.log"
      partitions: 3
      retention_ms: 604800000
```

### 2. Setup Pipeline Trigger
```yaml
# In your source project's .gitlab-ci.yml
include:
  - local: 'terraform-ci.yml'

stages:
  - prepare
  - trigger

prepare_config:
  stage: prepare
  script:
    - cp factory-config.yml $CONFIG_FILE_NAME
```

### 3. Monitor Execution
- Check pipeline progress in factory project
- Review Terraform plan
- Manually approve apply stage

## 🔍 Troubleshooting

Common issues and solutions:

1. **Pipeline Not Triggering**
   - Check source project permissions
   - Verify trigger configuration
   - Ensure CONFIG_FILE exists

2. **State Lock Issues**
   - Check for existing locks
   - Verify GitLab API access
   - Ensure proper credentials

3. **Configuration Errors**
   - Validate YAML syntax
   - Check resource naming conventions
   - Verify required fields

## 📚 Related Documentation

- [GitLab CI Documentation](https://docs.gitlab.com/ee/ci/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform HTTP Backend](https://www.terraform.io/docs/language/settings/backends/http.html)

## 💡 Contributing

1. Fork the factory project
2. Create your feature branch
3. Submit merge request with:
   - Clear description of changes
   - Updated documentation
   - Test results

## 📧 Support

For issues or questions:
- Create GitLab issue
- Contact platform team
- Check troubleshooting guide
