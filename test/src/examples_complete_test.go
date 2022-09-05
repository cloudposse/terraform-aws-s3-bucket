package test

import (
	"bytes"
	"encoding/json"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	testStructure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"os"
	"strings"
	"testing"
)

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
	terraform.Destroy(t, terraformOptions)
	os.RemoveAll(tempTestFolder)
}

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	userName := terraform.Output(t, terraformOptions, "user_name")

	expectedUserName := "eg-test-s3-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedUserName, userName)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	expectedS3BucketId := "eg-test-s3-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)

	// Run `terraform output` to get the value of an output variable
	accessKeyID := terraform.Output(t, terraformOptions, "access_key_id")

	// Verify we're getting back the outputs we expect
	assert.NotEmpty(t, accessKeyID)

	// Run `terraform output` to get the value of an output variable
	secretAccessKey := terraform.Output(t, terraformOptions, "secret_access_key")

	// Verify we're getting back the outputs we expect
	assert.NotEmpty(t, secretAccessKey)

	// Run `terraform output` to get the value of an output variable
	accessKeyIDPath := terraform.Output(t, terraformOptions, "access_key_id_ssm_path")

	// Verify we're getting back the outputs we expect
	assert.Empty(t, accessKeyIDPath)

	// Run `terraform output` to get the value of an output variable
	secretAccessKeyPath := terraform.Output(t, terraformOptions, "secret_access_key_ssm_path")

	// Verify we're getting back the outputs we expect
	assert.Empty(t, secretAccessKeyPath)
}

// Ensure that the s3 user's access key is not created when not wanted.
func TestExamplesCompleteWithoutAccessKey(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes":         attributes,
			"access_key_enabled": false,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	userName := terraform.Output(t, terraformOptions, "user_name")

	expectedUserName := "eg-test-s3-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedUserName, userName)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	expectedS3BucketId := "eg-test-s3-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)

	// Run `terraform output` to get the value of an output variable
	accessKeyID := terraform.Output(t, terraformOptions, "access_key_id")

	// Verify we're getting back the outputs we expect
	assert.Empty(t, accessKeyID)

	// Run `terraform output` to get the value of an output variable
	secretAccessKey := terraform.Output(t, terraformOptions, "secret_access_key")

	// Verify we're getting back the outputs we expect
	assert.Empty(t, secretAccessKey)

	// Run `terraform output` to get the value of an output variable
	accessKeyIDPath := terraform.Output(t, terraformOptions, "access_key_id_ssm_path")

	// Verify we're getting back the outputs we expect
	assert.Empty(t, accessKeyIDPath)

	// Run `terraform output` to get the value of an output variable
	secretAccessKeyPath := terraform.Output(t, terraformOptions, "secret_access_key_ssm_path")

	// Verify we're getting back the outputs we expect
	assert.Empty(t, secretAccessKeyPath)
}

// Ensure that the s3 user's access key is stored in SSM when desired.
func TestExamplesCompleteWithAccessKeyInSSM(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes":              attributes,
			"access_key_enabled":      true,
			"store_access_key_in_ssm": true,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	userName := terraform.Output(t, terraformOptions, "user_name")

	expectedUserName := "eg-test-s3-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedUserName, userName)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	expectedS3BucketId := "eg-test-s3-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)

	// Run `terraform output` to get the value of an output variable
	accessKeyID := terraform.Output(t, terraformOptions, "access_key_id")

	// Verify we're getting back the outputs we expect
	assert.NotEmpty(t, accessKeyID)

	// Run `terraform output` to get the value of an output variable
	secretAccessKey := terraform.Output(t, terraformOptions, "secret_access_key")

	// Verify we're getting back the outputs we expect
	assert.Empty(t, secretAccessKey)

	// Run `terraform output` to get the value of an output variable
	accessKeyIDPath := terraform.Output(t, terraformOptions, "access_key_id_ssm_path")

	// Verify we're getting back the outputs we expect
	if assert.NotEmpty(t, accessKeyIDPath) {
		assert.Equal(t, accessKeyID, aws.GetParameter(t, "us-east-2", accessKeyIDPath))
	}

	// Run `terraform output` to get the value of an output variable
	secretAccessKeyPath := terraform.Output(t, terraformOptions, "secret_access_key_ssm_path")

	// Verify we're getting back the outputs we expect
	if assert.NotEmpty(t, secretAccessKeyPath) {
		assert.NotEmpty(t, aws.GetParameter(t, "us-east-2", secretAccessKeyPath))
	}
}

// Test the Terraform module in examples/complete using Terratest for grants.
func TestExamplesCompleteWithGrants(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"grants.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	expectedS3BucketId := "eg-test-s3-grants-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)
}

// Test the Terraform module in examples/complete using Terratest for grants.
func TestExamplesCompleteWithObjectLock(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"object-lock.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")
	expectedS3BucketId := "eg-test-s3-object-lock-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)
}

func TestExamplesCompleteWithLifecycleRules(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"lifecycle.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	expectedS3BucketId := "eg-test-s3-lifecycle-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)
}

func TestExamplesCompleteWithReplication(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"replication.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
			"enabled":    "true",
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	expectedS3BucketId := "eg-test-s3-replication-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)

	// Run `terraform output` to get the value of an output variable
	s3ReplicationBucketId := terraform.Output(t, terraformOptions, "replication_bucket_id")

	expectedReplicationS3BucketId := "eg-test-s3-replication-test-" + attributes[0] + "-target"
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedReplicationS3BucketId, s3ReplicationBucketId)

	// Run `terraform output` to get the value of an output variable
	s3ReplicationRoleArn := terraform.Output(t, terraformOptions, "replication_role_arn")

	// Verify we're getting back the outputs we expect
	assert.NotEmptyf(t, s3ReplicationRoleArn, "If replication is enabled, we should get a Replication Role ARN.")
}

func TestExamplesCompleteWithPrivilegedPrincipals(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	awsRegion := "us-east-2"
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"privileged-principals.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
			"enabled":    "true",
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	expectedS3BucketId := "eg-test-s3-principals-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)

	// Run `terraform output` to get the value of an output variable
	bucketID := terraform.Output(t, terraformOptions, "bucket_id")

	// Verify that our Bucket has a policy attached
	aws.AssertS3BucketPolicyExists(t, awsRegion, bucketID)

	// Verify that our bucket's bucket policy contains the expected statements allowing actions made by privileged principals
	bucketPolicy := aws.GetS3BucketPolicy(t, awsRegion, bucketID)
	expectedBucketPolicyStatementsTemplate := `
    [{
        "Sid": "AllowPrivilegedPrincipal[0]",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::AWS_ACCOUNT_ID:role/eg-test-s3-principals-test-RANDOM_ID-deployment"
        },
        "Action": [
            "s3:PutObjectAcl",
            "s3:PutObject",
            "s3:ListBucketMultipartUploads",
            "s3:ListBucket",
            "s3:GetObject",
            "s3:GetBucketLocation",
            "s3:DeleteObject",
            "s3:AbortMultipartUpload"
        ],
        "Resource": [
            "arn:aws:s3:::eg-test-s3-principals-test-RANDOM_ID/*",
            "arn:aws:s3:::eg-test-s3-principals-test-RANDOM_ID"
        ]
    },
    {
        "Sid": "AllowPrivilegedPrincipal[1]",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::AWS_ACCOUNT_ID:role/eg-test-s3-principals-test-RANDOM_ID-deployment-additional"
        },
        "Action": [
            "s3:PutObjectAcl",
            "s3:PutObject",
            "s3:ListBucketMultipartUploads",
            "s3:ListBucket",
            "s3:GetObject",
            "s3:GetBucketLocation",
            "s3:DeleteObject",
            "s3:AbortMultipartUpload"
        ],
        "Resource": [
            "arn:aws:s3:::eg-test-s3-principals-test-RANDOM_ID/prefix2/*",
            "arn:aws:s3:::eg-test-s3-principals-test-RANDOM_ID/prefix1/*",
            "arn:aws:s3:::eg-test-s3-principals-test-RANDOM_ID"
        ]
    }]
    `
	expectedBucketPolicyStatements := strings.ReplaceAll(
		strings.ReplaceAll(
			expectedBucketPolicyStatementsTemplate,
			"AWS_ACCOUNT_ID",
			aws.GetAccountId(t),
		),
		"RANDOM_ID",
		attributes[0],
	)
	expectedBucketPolicyStatementsJSON := new(bytes.Buffer)
	err := json.Compact(expectedBucketPolicyStatementsJSON, []byte(expectedBucketPolicyStatements))
	if err != nil {
		t.Errorf("Unexpected error when compacting JSON: %v.", err)
	}
	expectedBucketPolicySnippet := strings.Trim(expectedBucketPolicyStatementsJSON.String(), "[]")
	assert.Contains(t, bucketPolicy, expectedBucketPolicySnippet)
}

// We do not have a good way to test the S3 website, so we just test that the Terraform `apply` succeeded.
// That would be enough to catch a regression of https://github.com/cloudposse/terraform-aws-s3-bucket/issues/141
func TestExamplesCompleteWithWebsite(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"website.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	expectedS3BucketId := "eg-test-s3-test-website-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)
}

// We do not have a good way to test the S3 website, so we just test that the Terraform `apply` succeeded.
// That would be enough to catch a regression of https://github.com/cloudposse/terraform-aws-s3-bucket/issues/141
func TestExamplesCompleteWithWebsiteRedirectAll(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"website-redirect.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	expectedS3BucketId := "eg-test-s3-test-website-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)
}

func TestExamplesCompleteDisabled(t *testing.T) {
	t.Parallel()
	randID := strings.ToLower(random.UniqueId())
	attributes := []string{randID}

	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := testStructure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: varFiles,
		Vars: map[string]interface{}{
			"attributes": attributes,
			"enabled":    "false",
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer cleanup(t, terraformOptions, tempTestFolder)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform outputAll` to get a map of all the output values,
	// because null outputs are not retrieved by terraform.Output().
	output := terraform.OutputAll(t, terraformOptions)

	assert.Empty(t, output["user_name"], "When disabled, module should have no outputs.")
	assert.Empty(t, output["bucket_id"], "When disabled, module should have no outputs.")
	assert.Empty(t, output["replication_bucket_id"], "When disabled, module should have no outputs.")

}
