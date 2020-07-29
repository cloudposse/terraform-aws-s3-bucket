package test

import (
	"math/rand"
	"strconv"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	rand.Seed(time.Now().UnixNano())

	attributes := []string{strconv.Itoa(rand.Intn(100000))}
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"fixtures.us-west-1.tfvars"}

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
	rand.Seed(time.Now().UnixNano())

	attributes := []string{strconv.Itoa(rand.Intn(100000))}
	rootFolder := "../../"
	terraformFolderRelativeToRoot := "examples/complete"
	varFiles := []string{"grants.us-west-1.tfvars"}

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

	expectedUserName := "eg-test-s3-grants-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedUserName, userName)

	// Run `terraform output` to get the value of an output variable
	s3BucketId := terraform.Output(t, terraformOptions, "bucket_id")

	expectedS3BucketId := "eg-test-s3-grants-test-" + attributes[0]
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedS3BucketId, s3BucketId)
}
