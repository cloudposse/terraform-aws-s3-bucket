package test

import (
	"bytes"
	"encoding/json"
	"math/rand"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()
	rand.Seed(time.Now().UnixNano())

	attributes := []string{strconv.Itoa(rand.Intn(100000))}
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-east-2.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

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
	defer terraform.Destroy(t, terraformOptions)

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
}

// Test the Terraform module in examples/complete using Terratest for grants.
func TestExamplesCompleteWithGrants(t *testing.T) {
	t.Parallel()
	rand.Seed(time.Now().UnixNano() + 1)

	attributes := []string{strconv.Itoa(rand.Intn(100000))}
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"grants.us-east-2.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

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
	defer terraform.Destroy(t, terraformOptions)

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
	rand.Seed(time.Now().UnixNano() + 2)

	attributes := []string{strconv.Itoa(rand.Intn(100000))}
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"object-lock.us-east-2.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

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
	defer terraform.Destroy(t, terraformOptions)

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
	rand.Seed(time.Now().UnixNano() + 3)

	attributes := []string{strconv.Itoa(rand.Intn(100000))}
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"lifecycle.us-east-2.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

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
	defer terraform.Destroy(t, terraformOptions)

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
	rand.Seed(time.Now().UnixNano() + 4)

	attributes := []string{strconv.Itoa(rand.Intn(100000))}
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"replication.us-east-2.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

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
	defer terraform.Destroy(t, terraformOptions)

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
	rand.Seed(time.Now().UnixNano() + 5)

	awsRegion := "us-east-2"
	attributes := []string{strconv.Itoa(rand.Intn(100000))}
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"privileged-principals.us-east-2.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

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
	defer terraform.Destroy(t, terraformOptions)

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

func TestExamplesCompleteDisabled(t *testing.T) {
	t.Parallel()
	rand.Seed(time.Now().UnixNano() + 6)

	attributes := []string{strconv.Itoa(rand.Intn(100000))}
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"replication.us-east-2.tfvars"}

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

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
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	userName := terraform.Output(t, terraformOptions, "user_name")

	// Verify we're getting back the outputs we expect
	assert.Empty(t, userName, "When disabled, module should have no outputs.")

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	// Verify we're getting back the outputs we expect
	assert.Empty(t, s3BucketId, "When disabled, module should have no outputs.")

	// Run `terraform output` to get the value of an output variable
	s3ReplicationBucketId := terraform.Output(t, terraformOptions, "replication_bucket_id")

	// Verify we're getting back the outputs we expect
	assert.Empty(t, s3ReplicationBucketId, "When disabled, module should have no outputs.")

}
