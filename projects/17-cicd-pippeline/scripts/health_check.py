#!/usr/bin/env python3
"""Health check script for CICD deployment validation."""

import sys
import json
import time

def check_s3_bucket(bucket_name: str) -> dict[str, bool]:
    """Check S3 bucket accessibility and basic properties."""
    import boto3
    from botocore.exceptions import ClientError

    results = {}
    try:
        s3_client = boto3.client('s3')

        # Check bucket exists
        try:
            s3_client.head_bucket(Bucket=bucket_name)
            results['bucket_exists'] = True
        except ClientError as e:
            results['bucket_exists'] = False
            print(f"ERROR: Bucket {bucket_name} not found: {e}")
            return results

        # Check versioning is enabled
        versioning = s3_client.get_bucket_versioning(Bucket=bucket_name)
        results['versioning_enabled'] = versioning.get('Status') == 'Enabled'

        # Check bucket tags
        try:
            tags_response = s3_client.get_bucket_tagging(Bucket=bucket_name)
            tag_dict = {tag['Key']: tag['Value'] for tag in tags_response.get('TagSet', [])}
            results['has_environment_tag'] = 'Environment' in tag_dict
            results['has_project_tag'] = 'Project' in tag_dict
        except ClientError:
            results['has_environment_tag'] = False
            results['has_project_tag'] = False

        return results
    except Exception as e:
        print(f"ERROR during S3 check: {e}")
        return {'bucket_exists': False}

def health_check() -> bool:
    """Run all health checks and return overall status."""
    import os

    bucket_name = os.environ.get('S3_BUCKET_NAME')
    environment = os.environ.get('ENVIRONMENT', 'unknown')

    if not bucket_name:
        print("ERROR: S3_BUCKET_NAME environment variable not set")
        return False

    print(f"Starting health checks for {environment} environment...")
    print(f"Checking S3 bucket: {bucket_name}")

    checks = check_s3_bucket(bucket_name)

    print("\nHealth Check Results:")
    print(json.dumps(checks, indent=2))

    # Determine overall status
    required_checks = ['bucket_exists', 'versioning_enabled']
    all_required_pass = all(checks.get(check, False) for check in required_checks)

    if all_required_pass:
        print("\n✓ Health check PASSED")
        return True
    else:
        print("\n✗ Health check FAILED")
        return False

if __name__ == '__main__':
    success = health_check()
    sys.exit(0 if success else 1)
